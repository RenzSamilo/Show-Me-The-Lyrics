import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property bool cfg_overlayEnabled
    property int cfg_overlayAnchor
    property int cfg_overlayMarginX
    property int cfg_overlayMarginY
    property int cfg_overlayWidth
    property int cfg_overlayOpacity
    property bool cfg_overlayRandom
    property int cfg_overlayRandomArea
    property bool cfg_overlayHidesWidget

    Kirigami.FormLayout {
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Overlay:")
            text: i18n("Show lyrics on top of all windows")
            checked: cfg_overlayEnabled
            onToggled: cfg_overlayEnabled = checked
        }
        QQC2.Label {
            text: i18n("Click-through, like an in-game HUD. Styled the same as the widget.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }

        QQC2.CheckBox {
            text: i18n("Hide the widget's own lyrics while the overlay is on")
            enabled: cfg_overlayEnabled
            checked: cfg_overlayHidesWidget
            onToggled: cfg_overlayHidesWidget = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Random position:")
            text: i18n("Jump to a new spot on every line")
            enabled: cfg_overlayEnabled
            checked: cfg_overlayRandom
            onToggled: cfg_overlayRandom = checked
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Use the top:")
            enabled: cfg_overlayEnabled && cfg_overlayRandom
            from: 20
            suffix: i18n("% of the screen")
            value: cfg_overlayRandomArea
            onMoved: v => cfg_overlayRandomArea = v
        }
        QQC2.Label {
            visible: cfg_overlayRandom
            text: i18n("Shows only the current line. Pop or Fade (Animation page) suits it best.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }

        // 3x3 picker: which part of the screen the overlay sticks to
        Grid {
            Kirigami.FormData.label: i18n("Screen position:")
            enabled: cfg_overlayEnabled && !cfg_overlayRandom
            columns: 3
            spacing: 2
            Repeater {
                model: [i18n("Top left"), i18n("Top"), i18n("Top right"),
                        i18n("Left"), i18n("Centre"), i18n("Right"),
                        i18n("Bottom left"), i18n("Bottom"), i18n("Bottom right")]
                QQC2.Button {
                    required property string modelData
                    required property int index
                    width: Kirigami.Units.gridUnit * 3
                    height: Kirigami.Units.gridUnit * 2
                    checkable: true
                    checked: cfg_overlayAnchor === index
                    onClicked: cfg_overlayAnchor = index
                    Accessible.name: modelData
                    QQC2.ToolTip.text: modelData
                    QQC2.ToolTip.visible: hovered
                }
            }
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Distance from side (px):")
            enabled: cfg_overlayEnabled && !cfg_overlayRandom && cfg_overlayAnchor % 3 !== 1
            from: 0; to: 4000; stepSize: 10
            value: cfg_overlayMarginX
            onValueModified: cfg_overlayMarginX = value
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Distance from top/bottom (px):")
            enabled: cfg_overlayEnabled && !cfg_overlayRandom && Math.floor(cfg_overlayAnchor / 3) !== 1
            from: 0; to: 4000; stepSize: 10
            value: cfg_overlayMarginY
            onValueModified: cfg_overlayMarginY = value
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Width (px):")
            enabled: cfg_overlayEnabled
            from: 200; to: 8000; stepSize: 20
            value: cfg_overlayWidth
            onValueModified: cfg_overlayWidth = value
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Opacity:")
            enabled: cfg_overlayEnabled
            from: 10
            value: cfg_overlayOpacity
            onMoved: v => cfg_overlayOpacity = v
        }
    }
}
