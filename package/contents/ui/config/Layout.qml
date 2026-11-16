import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property int cfg_linesBefore
    property int cfg_linesAfter
    property int cfg_alignment
    property int cfg_lineSpacing
    property int cfg_inactiveScale
    property int cfg_inactiveOpacity
    property bool cfg_wrap
    property int cfg_panelWidth

    Kirigami.FormLayout {
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Lines before:")
            from: 0; to: 8
            value: cfg_linesBefore
            onValueModified: cfg_linesBefore = value
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Lines after:")
            from: 0; to: 8
            value: cfg_linesAfter
            onValueModified: cfg_linesAfter = value
        }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Alignment:")
            model: [i18n("Left"), i18n("Centre"), i18n("Right")]
            currentIndex: cfg_alignment
            onActivated: cfg_alignment = currentIndex
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Line spacing (px):")
            from: 0; to: 100
            value: cfg_lineSpacing
            onValueModified: cfg_lineSpacing = value
        }
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Long lines:")
            text: i18n("Wrap instead of cutting off")
            checked: cfg_wrap
            onToggled: cfg_wrap = checked
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Other lines") }

        PercentSlider {
            Kirigami.FormData.label: i18n("Size:")
            from: 30; to: 100
            value: cfg_inactiveScale
            onMoved: v => cfg_inactiveScale = v
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Opacity:")
            value: cfg_inactiveOpacity
            onMoved: v => cfg_inactiveOpacity = v
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("In a panel") }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Width (px):")
            from: 100; to: 3000; stepSize: 20
            value: cfg_panelWidth
            onValueModified: cfg_panelWidth = value
        }
        QQC2.Label {
            text: i18n("A panel shows only the current line, sized to fit.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }
    }
}
