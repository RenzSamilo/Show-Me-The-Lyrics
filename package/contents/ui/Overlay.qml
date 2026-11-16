import QtQuick
import QtQuick.Window
import org.kde.layershell as LayerShell

// Click-through lyrics HUD above all windows (Wayland layer-shell).
// The margin is transparent padding inside the window, on the anchored side.
Window {
    id: win

    required property var engine
    readonly property var cfg: engine.cfg
    // overlayAnchor is a 3x3 grid index: 0 top-left ... 8 bottom-right
    readonly property int row: Math.floor(cfg.overlayAnchor / 3)
    readonly property int col: cfg.overlayAnchor % 3
    readonly property int marginX: col === 1 ? 0 : cfg.overlayMarginX
    readonly property int marginY: row === 1 ? 0 : cfg.overlayMarginY

    visible: engine.shouldShow
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
    width: Math.min(cfg.overlayWidth, Screen.width) + marginX
    height: view.implicitHeight + marginY

    LayerShell.Window.scope: "smtl-lyrics"
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.anchors: (row === 0 ? LayerShell.Window.AnchorTop : row === 2 ? LayerShell.Window.AnchorBottom : LayerShell.Window.AnchorNone)
        | (col === 0 ? LayerShell.Window.AnchorLeft : col === 2 ? LayerShell.Window.AnchorRight : LayerShell.Window.AnchorNone)

    LyricsView {
        id: view
        x: win.col === 0 ? win.marginX : 0
        y: win.row === 0 ? win.marginY : 0
        width: win.width - win.marginX
        height: implicitHeight
        opacity: win.cfg.overlayOpacity / 100
        animate: win.visible
        cfg: win.cfg
        lines: win.engine.lines
        currentIndex: win.engine.currentIndex
        progress: win.engine.progress
        fallbackText: win.engine.fallbackText
    }
}
