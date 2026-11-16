import QtQuick
import "../code/style.js" as Style

// The lyrics display: current line plus a few before/after. Used by the widget and the overlay.
//
// All lines sit in one Column that is shifted so the current line lands on a fixed slot.
// The shift is a plain binding on the current line's position, so the display can't drift
// from the engine's index (a ListView in StrictlyEnforceRange mode re-picks its own current
// item whenever line heights change, which scrolled the real current line out of view).
Item {
    id: view

    required property var cfg
    property var lines: []          // [{t, text}]
    property int currentIndex: -1
    property real progress: 0
    property string fallbackText: ""  // shown when there are no lines
    property bool compact: false      // current line only (panel, random overlay)
    property real sizeOverride: 0     // panel: font size fitted to the panel
    property bool animate: true       // false while hidden, to stop the effect clock
    property bool scrollAnimated: true  // false where the view itself jumps around

    readonly property int before: compact ? 0 : cfg.linesBefore
    readonly property int after: compact ? 0 : cfg.linesAfter
    readonly property real activeSize: sizeOverride > 0 ? sizeOverride : cfg.fontSize
    readonly property real pad: compact ? 0 : Math.round(activeSize * 0.4)
    readonly property real fxTime: clock.elapsedTime

    FontMetrics { id: activeFm; font: Style.font(view.cfg, view.activeSize) }
    FontMetrics { id: inactiveFm; font: Style.font(view.cfg, view.activeSize * view.cfg.inactiveScale / 100) }
    readonly property real inactiveStep: inactiveFm.height + cfg.lineSpacing

    // the current line's item; re-read when the index or the set of lines changes
    readonly property Item currentItem: (rows.count, currentIndex >= 0 ? rows.itemAt(currentIndex) : null)
    // a wrapped current line is taller than one row; grow with it so the lines after stay visible
    readonly property real activeH: Math.max(activeFm.height, currentItem ? currentItem.height : 0)
    readonly property real slotY: pad + before * inactiveStep

    implicitHeight: (before + after) * inactiveStep + activeH + 2 * pad
    clip: true

    FrameAnimation {
        id: clock
        running: view.animate && view.visible && (view.cfg.wave || view.cfg.colorMode === 2)
    }

    Rectangle {
        anchors.fill: parent
        visible: view.cfg.backdrop
        color: Style.alpha(view.cfg.backdropColor, view.cfg.backdropOpacity / 100)
        radius: view.cfg.backdropRadius
    }

    Column {
        id: column
        x: view.pad
        width: view.width - 2 * view.pad
        spacing: view.cfg.lineSpacing
        // before the first line (index -1), park line 0 in the "next line" slot
        y: view.currentItem ? view.slotY - view.currentItem.y : view.slotY + view.inactiveStep
        Behavior on y {
            enabled: view.scrollAnimated && view.cfg.transition === 1
            NumberAnimation { duration: view.cfg.transitionMs; easing.type: Easing.OutCubic }
        }

        Repeater {
            id: rows
            model: view.lines
            LyricLine {
                required property var modelData
                required property int index
                readonly property int distance: index - view.currentIndex
                // Far-away lines take one fixed row, so re-wrapping them (width changes)
                // can't move the current line.
                readonly property bool near: distance >= -view.before - 1 && distance <= view.after + 1

                width: column.width
                height: near ? implicitHeight : inactiveFm.height
                cfg: view.cfg
                activeSize: view.activeSize
                text: modelData.text
                active: distance === 0
                rendered: opacity > 0
                progress: active ? view.progress : 0
                fxTime: active ? view.fxTime : 0
                opacity: distance < -view.before || distance > view.after ? 0 : active ? 1 : view.cfg.inactiveOpacity / 100
                Behavior on opacity {
                    enabled: view.cfg.transition !== 0
                    NumberAnimation { duration: view.cfg.transitionMs }
                }
            }
        }
    }

    LyricLine {
        visible: view.lines.length === 0 && view.fallbackText !== ""
        anchors.verticalCenter: parent.verticalCenter
        x: view.pad
        width: parent.width - 2 * view.pad
        cfg: view.cfg
        activeSize: view.activeSize
        text: view.fallbackText
        active: true
        fxTime: view.fxTime
    }
}
