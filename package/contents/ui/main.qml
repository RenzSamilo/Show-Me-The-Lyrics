import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mpris as Mpris
import "../code/lyrics.js" as Lyrics
import "../code/style.js" as Style

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration
    readonly property bool horizontalPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    readonly property bool inPanel: horizontalPanel || Plasmoid.formFactor === PlasmaCore.Types.Vertical

    Fonts {}

    // ---- style ----
    // Normally the config itself. With shuffle on: a snapshot of the config overlaid with a
    // preset picked at random for each line.
    property var styleCfg: cfg
    property var shufflePreset: null

    function restyle(reroll) {
        var pool = cfg.shuffleEnabled ? Style.shufflePool(cfg) : [];
        if (pool.length === 0) {
            shufflePreset = null;
            styleCfg = cfg;
            return;
        }
        var last = shufflePreset ? shufflePreset.name : "";
        var keep = pool.filter(function (p) { return p.name === last; })[0];
        if (reroll || !keep) {
            // don't repeat the previous line's preset when there is a choice
            var choices = pool.length > 1 ? pool.filter(function (p) { return p.name !== last; }) : pool;
            keep = choices[Math.floor(Math.random() * choices.length)];
        }
        shufflePreset = keep;
        var snapshot = {};
        cfg.keys().forEach(function (k) { snapshot[k] = cfg[k]; });
        styleCfg = Object.assign(snapshot, Style.resolve(keep.style));
    }
    onCurrentIndexChanged: restyle(true)
    Connections {
        target: root.cfg
        function onValueChanged() { root.restyle(false); }   // any setting changed: rebuild the snapshot
    }

    // ---- player ----
    property var player: null
    readonly property string playerMode: cfg.playerMode
    onPlayerModeChanged: pickPlayer()

    Mpris.Mpris2Model {
        id: mpris
        onCurrentPlayerChanged: root.pickPlayer()
    }
    Instantiator {
        id: players
        model: mpris
        delegate: QtObject {
            required property var container
            required property bool isMultiplexer
        }
        onObjectAdded: Qt.callLater(root.pickPlayer)
        onObjectRemoved: Qt.callLater(root.pickPlayer)
    }

    function pickPlayer() {
        if (cfg.playerMode !== "spotify") {
            player = mpris.currentPlayer;
            return;
        }
        for (var i = 0; i < players.count; i++) {
            var p = players.objectAt(i);
            if (p && !p.isMultiplexer && p.container && /spotify/i.test(p.container.identity + p.container.desktopEntry)) {
                player = p.container;
                return;
            }
        }
        player = null;
    }

    readonly property string track: player?.track ?? ""
    readonly property string artist: player?.artist ?? ""
    readonly property string album: player?.album ?? ""
    readonly property real lengthMs: (player?.length ?? 0) / 1000
    readonly property bool playing: player?.playbackStatus === Mpris.PlaybackStatus.Playing

    // ---- position: MPRIS only reports it on request, so extrapolate between samples ----
    property real basePos: 0
    property double baseAt: 0

    function resync() {
        basePos = (player?.position ?? 0) / 1000;
        baseAt = Date.now();
        update();
    }
    onPlayerChanged: resync()
    Connections {
        target: root.player
        function onPositionChanged() { root.resync(); }
        function onPlaybackStatusChanged() { root.player.updatePosition(); root.resync(); }
    }
    Timer {
        interval: 1000; repeat: true
        running: root.playing
        onTriggered: root.player.updatePosition()
    }

    // ---- lyrics ----
    property var lines: []
    property int currentIndex: -1
    property real progress: 0
    property bool loading: false
    property var cache: ({})
    property int requestId: 0

    readonly property string trackKey: track + "\n" + artist
    onTrackKeyChanged: {
        lines = [];
        currentIndex = -1;
        loading = track !== "";
        debounce.restart();
    }
    // metadata arrives field by field; wait for it to settle before asking
    Timer { id: debounce; interval: 400; onTriggered: root.load() }

    function load() {
        if (!track) return;
        var key = trackKey, id = ++requestId;
        if (cache[key]) return apply(cache[key]);
        Lyrics.fetchLyrics(track, artist, album, lengthMs / 1000, function (found) {
            if (found) root.cache[key] = found;
            if (id === root.requestId) root.apply(found || []);
        });
    }
    function apply(found) {
        lines = found;
        loading = false;
        resync();
    }

    function update() {
        var pos = basePos + cfg.offsetMs + (playing ? (Date.now() - baseAt) * (player.rate || 1) : 0);
        var i = Lyrics.indexAt(lines, pos);
        currentIndex = i;
        if (i < 0) { progress = 0; return; }
        var start = lines[i].t;
        var span = (i + 1 < lines.length ? lines[i + 1].t : start + 5000) - start;
        // LRCLIB has no word timings: sweep the line evenly, but don't crawl through long gaps
        span = Math.min(span, Math.max(1500, lines[i].text.length * 150));
        progress = Math.max(0, Math.min(1, (pos - start) / span));
    }
    Timer {
        interval: 33; repeat: true
        running: root.playing && root.lines.length > 0
        onTriggered: root.update()
    }

    readonly property string fallbackText: lines.length === 0 && cfg.showTrackInfo && track
        ? "♪ " + track + (artist ? " — " + artist : "") : ""
    readonly property bool shouldShow: track !== "" && (playing || cfg.showWhenPaused) && (lines.length > 0 || fallbackText !== "")
    // with the overlay up, the widget's own copy would just be a duplicate
    readonly property bool widgetShows: shouldShow && !(cfg.overlayEnabled && cfg.overlayHidesWidget)

    // ---- overlay: loaded by URL so a missing layer-shell module can't break the widget ----
    Loader { id: overlay }
    readonly property bool overlayEnabled: cfg.overlayEnabled
    onOverlayEnabledChanged: syncOverlay()
    function syncOverlay() {
        if (cfg.overlayEnabled) overlay.setSource("Overlay.qml", { engine: root });
        else overlay.source = "";
    }

    Component.onCompleted: {
        restyle(true);
        pickPlayer();
        syncOverlay();
    }

    // ---- widget ----
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: root.cfg.overlayEnabled ? i18n("Hide Overlay") : i18n("Show Overlay")
            icon.name: "window-pin"
            onTriggered: root.cfg.overlayEnabled = !root.cfg.overlayEnabled
        }
    ]
    toolTipMainText: track || i18n("Show Me The Lyrics")
    toolTipSubText: artist

    preferredRepresentation: fullRepresentation
    fullRepresentation: LyricsView {
        Layout.minimumWidth: root.inPanel ? 100 : 200
        Layout.preferredWidth: root.inPanel ? root.cfg.panelWidth : 520
        Layout.preferredHeight: root.horizontalPanel ? -1 : implicitHeight
        Layout.minimumHeight: root.inPanel ? 0 : 40

        cfg: root.styleCfg
        compact: root.inPanel
        // fit the panel thickness; a vertical panel has no fixed height to fit, so use a small fixed size
        sizeOverride: root.horizontalPanel ? Math.min(root.cfg.fontSize, root.height * 0.6)
            : root.inPanel ? Math.min(root.cfg.fontSize, 14) : 0
        opacity: root.widgetShows ? 1 : 0
        animate: root.widgetShows
        lines: root.lines
        currentIndex: root.currentIndex
        progress: root.progress
        fallbackText: root.fallbackText
    }
}
