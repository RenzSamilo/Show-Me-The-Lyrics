import QtQuick
import "../code/style.js" as Style

// The lyrics display: current line plus a few before/after. Used by the widget and the overlay.
Item {
    id: view

    required property var cfg
    property var lines: []          // [{t, text}]
    property int currentIndex: -1
    property real progress: 0
    property string fallbackText: ""  // shown when there are no lines
    property bool compact: false      // panel: current line only
    property real sizeOverride: 0     // panel: font size fitted to the panel
    property bool animate: true       // false while hidden, to stop the effect clock

    readonly property int before: compact ? 0 : cfg.linesBefore
    readonly property int after: compact ? 0 : cfg.linesAfter
    readonly property real activeSize: sizeOverride > 0 ? sizeOverride : cfg.fontSize
    readonly property real pad: compact ? 0 : Math.round(activeSize * 0.4)
    readonly property real fxTime: clock.elapsedTime

    FontMetrics { id: activeFm; font: Style.font(view.cfg, view.activeSize) }
    FontMetrics { id: inactiveFm; font: Style.font(view.cfg, view.activeSize * view.cfg.inactiveScale / 100) }
    readonly property real inactiveStep: inactiveFm.height + cfg.lineSpacing

    // a wrapped current line is taller than one row; grow with it so the lines after stay visible
    readonly property real activeH: Math.max(activeFm.height, list.currentItem ? list.currentItem.implicitHeight : 0)

    implicitHeight: (before + after) * inactiveStep + activeH + 2 * pad

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

    ListView {
        id: list
        anchors.fill: parent
        anchors.leftMargin: view.pad
        anchors.rightMargin: view.pad
        visible: view.lines.length > 0
        clip: true
        interactive: false
        model: view.lines
        currentIndex: view.currentIndex
        spacing: view.cfg.lineSpacing

        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: view.pad + view.before * view.inactiveStep
        preferredHighlightEnd: preferredHighlightBegin + view.activeH
        highlightMoveDuration: view.cfg.transition === 1 ? view.cfg.transitionMs : 0
        highlightMoveVelocity: -1

        delegate: LyricLine {
            required property var modelData
            required property int index
            readonly property int distance: index - view.currentIndex

            width: list.width
            cfg: view.cfg
            activeSize: view.activeSize
            text: modelData.text
            active: distance === 0
            progress: active ? view.progress : 0
            fxTime: active ? view.fxTime : 0
            opacity: distance < -view.before || distance > view.after ? 0 : active ? 1 : view.cfg.inactiveOpacity / 100
            Behavior on opacity {
                enabled: view.cfg.transition !== 0
                NumberAnimation { duration: view.cfg.transitionMs }
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
