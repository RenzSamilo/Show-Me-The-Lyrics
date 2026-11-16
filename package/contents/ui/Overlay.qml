import QtQuick
import QtQuick.Window
import org.kde.layershell as LayerShell
import "../code/style.js" as Style

// Click-through lyrics HUD above all windows (Wayland layer-shell).
// Fixed mode: a window the size of the lyrics, stuck to one of nine screen positions;
// the margin is transparent padding inside the window, on the anchored side.
// Random mode: a window covering the top part of the screen; the current line jumps
// to a new spot inside it on every line, so the window itself never has to move.
Window {
    id: win

    required property var engine
    readonly property var cfg: engine.cfg
    readonly property bool random: cfg.overlayRandom
    // overlayAnchor is a 3x3 grid index: 0 top-left ... 8 bottom-right
    readonly property int row: random ? 0 : Math.floor(cfg.overlayAnchor / 3)
    readonly property int col: random ? 0 : cfg.overlayAnchor % 3
    readonly property int marginX: random || col === 1 ? 0 : cfg.overlayMarginX
    readonly property int marginY: random || row === 1 ? 0 : cfg.overlayMarginY

    visible: engine.shouldShow
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
    width: random ? Screen.width : Math.min(cfg.overlayWidth, Screen.width) + marginX
    height: random ? Math.round(Screen.height * cfg.overlayRandomArea / 100) : view.implicitHeight + marginY

    LayerShell.Window.scope: "smtl-lyrics"
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.anchors: (row === 0 ? LayerShell.Window.AnchorTop : row === 2 ? LayerShell.Window.AnchorBottom : LayerShell.Window.AnchorNone)
        | (col === 0 ? LayerShell.Window.AnchorLeft : col === 2 ? LayerShell.Window.AnchorRight : LayerShell.Window.AnchorNone)

    // ---- random mode ----
    // Position as fractions of the free space, so the line stays on screen whatever its size.
    property real randX: 0.5
    property real randY: 0.5
    readonly property int lineIndex: engine.currentIndex
    onLineIndexChanged: if (random) { randX = Math.random(); randY = Math.random(); }

    // Shrink the box to the current line, otherwise a short line centred in a wide box barely moves.
    readonly property string currentText: {
        var t = lineIndex >= 0 && lineIndex < engine.lines.length ? engine.lines[lineIndex].text : engine.fallbackText;
        return cfg.uppercase ? t.toUpperCase() : t;
    }
    TextMetrics { id: measure; font: Style.font(win.cfg, win.cfg.fontSize); text: win.currentText }
    // + two font sizes of slack for glow, outline and per-letter spacing
    readonly property real randomWidth: Math.min(cfg.overlayWidth, win.width, measure.width + cfg.fontSize * 2)

    LyricsView {
        id: view
        x: win.random ? win.randX * (win.width - width) : win.col === 0 ? win.marginX : 0
        y: win.random ? win.randY * Math.max(0, win.height - height) : win.row === 0 ? win.marginY : 0
        width: win.random ? win.randomWidth : win.width - win.marginX
        height: implicitHeight
        opacity: win.cfg.overlayOpacity / 100
        animate: win.visible
        cfg: win.cfg
        compact: win.random   // current line only: neighbours would jump around with it
        lines: win.engine.lines
        currentIndex: win.engine.currentIndex
        progress: win.engine.progress
        fallbackText: win.engine.fallbackText
    }
}
