import QtQuick
import QtQuick.Effects
import "../code/style.js" as Style

// One lyric line, styled from cfg (the widget's config map, or a plain object for previews).
Item {
    id: line

    required property var cfg
    property string text
    property bool active: false
    property real progress: 0   // 0..1 through this line, for the karaoke fill
    property real fxTime: 0     // seconds, drives wave and rainbow
    property real activeSize: cfg.fontSize
    property bool rendered: true  // false skips drawing (and the shadow pass) but keeps the height

    // NFC: decomposed text (e.g. Hangul sent as separate jamo) becomes whole letters
    readonly property string shown: (cfg.uppercase ? text.toUpperCase() : text).normalize("NFC") || "♪"
    // Hebrew, Arabic, Indic, Thai: must be shaped as a whole, so no per-letter effects.
    readonly property bool complexScript: /[\u0590-\u0EFF\uFB1D-\uFDFF\uFE70-\uFEFF]/.test(shown)
    readonly property bool perLetter: active && !complexScript && (cfg.colorMode !== 0 || cfg.karaoke || cfg.wave)

    property real px: active ? activeSize : activeSize * cfg.inactiveScale / 100
    Behavior on px {
        enabled: line.cfg?.transition === 1
        NumberAnimation { duration: line.cfg.transitionMs; easing.type: Easing.OutCubic }
    }
    readonly property font textFont: Style.font(cfg, px)

    implicitHeight: content.implicitHeight

    onActiveChanged: {
        if (!active) return;
        // cfg can still be unset when a delegate is created already active
        if (cfg?.transition === 2) fadeIn.restart();
        else if (cfg?.transition === 3) pop.restart();
    }

    Item {
        id: holder
        anchors.fill: parent
        visible: line.rendered

        NumberAnimation { id: fadeIn; target: holder; property: "opacity"; from: 0; to: 1; duration: line.cfg.transitionMs }
        NumberAnimation { id: pop; target: holder; property: "scale"; from: 0.7; to: 1; duration: line.cfg.transitionMs; easing.type: Easing.OutBack }

        Item {
            id: content
            width: parent.width
            implicitHeight: line.perLetter ? letters.implicitHeight : plain.implicitHeight
            height: implicitHeight
            visible: line.cfg.shadowMode === 0   // otherwise drawn through the effect below

            Text {
                id: plain
                // opacity, not visible: this subtree is the hidden source of the effect below, and
                // Qt doesn't pick up visibility changes made inside an invisible parent
                opacity: line.perLetter ? 0 : 1
                width: parent.width
                text: line.shown
                font: line.textFont
                color: line.active ? line.cfg.textColor : line.cfg.inactiveColor
                horizontalAlignment: [Text.AlignLeft, Text.AlignHCenter, Text.AlignRight][line.cfg.alignment]
                wrapMode: line.cfg.wrap ? Text.Wrap : Text.NoWrap
                elide: line.cfg.wrap ? Text.ElideNone : Text.ElideRight
                style: line.cfg.outline ? Text.Outline : Text.Normal
                styleColor: line.cfg.outlineColor
            }

            FxText {
                id: letters
                opacity: line.perLetter ? 1 : 0
                width: parent.width
                cfg: line.cfg
                text: line.perLetter ? line.shown : ""
                font: line.textFont
                progress: line.progress
                fxTime: line.fxTime
            }
        }

        MultiEffect {
            source: content
            anchors.fill: content
            visible: line.cfg.shadowMode !== 0
            shadowEnabled: true
            shadowColor: line.cfg.shadowColor
            shadowBlur: line.cfg.shadowMode === 3 ? 0 : line.cfg.shadowStrength / 100
            shadowOpacity: 1
            blurMax: 40
            // glow sits right behind the text; a drop shadow is offset down-right;
            // a pixel shadow is a hard copy one "pixel" away, like Minecraft text
            shadowHorizontalOffset: line.cfg.shadowMode === 2 ? line.px * 0.05
                : line.cfg.shadowMode === 3 ? Math.max(1, Math.round(line.px * 0.1)) : 0
            shadowVerticalOffset: shadowHorizontalOffset
        }
    }
}
