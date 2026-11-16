import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQC
import ".." as Ui

KCM.SimpleKCM {
    property string cfg_fontFamily
    property int cfg_fontSize
    property bool cfg_bold
    property bool cfg_italic
    property bool cfg_uppercase
    property int cfg_letterSpacing
    property string cfg_textColor
    property int cfg_colorMode
    property string cfg_textColor2
    property string cfg_inactiveColor
    property bool cfg_outline
    property string cfg_outlineColor
    property int cfg_shadowMode
    property string cfg_shadowColor
    property int cfg_shadowStrength
    property bool cfg_backdrop
    property string cfg_backdropColor
    property int cfg_backdropOpacity
    property int cfg_backdropRadius

    Ui.Fonts { id: bundled }

    Kirigami.FormLayout {
        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Font") }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Family:")
            Layout.preferredWidth: 260
            // bundled fonts first, then everything installed
            model: [i18n("System default")].concat(bundled.families,
                Qt.fontFamilies().filter(f => bundled.families.indexOf(f) < 0))
            Component.onCompleted: currentIndex = cfg_fontFamily ? Math.max(0, find(cfg_fontFamily)) : 0
            onActivated: cfg_fontFamily = currentIndex === 0 ? "" : currentText
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Size (px):")
            from: 8; to: 200
            value: cfg_fontSize
            onValueModified: cfg_fontSize = value
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Look:")
            QQC2.CheckBox { text: i18n("Bold"); checked: cfg_bold; onToggled: cfg_bold = checked }
            QQC2.CheckBox { text: i18n("Italic"); checked: cfg_italic; onToggled: cfg_italic = checked }
            QQC2.CheckBox { text: i18n("UPPERCASE"); checked: cfg_uppercase; onToggled: cfg_uppercase = checked }
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Letter spacing:")
            from: -5; to: 30
            value: cfg_letterSpacing
            onValueModified: cfg_letterSpacing = value
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Colour") }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Current line:")
            model: [i18n("Solid"), i18n("Gradient"), i18n("Rainbow")]
            currentIndex: cfg_colorMode
            onActivated: cfg_colorMode = currentIndex
        }
        RowLayout {
            Kirigami.FormData.label: cfg_colorMode === 1 ? i18n("From / to:") : i18n("Colour:")
            enabled: cfg_colorMode !== 2
            KQC.ColorButton { color: cfg_textColor; onAccepted: cfg_textColor = color.toString() }
            KQC.ColorButton { visible: cfg_colorMode === 1; color: cfg_textColor2; onAccepted: cfg_textColor2 = color.toString() }
        }
        KQC.ColorButton {
            Kirigami.FormData.label: i18n("Other lines:")
            color: cfg_inactiveColor
            onAccepted: cfg_inactiveColor = color.toString()
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Effects") }

        RowLayout {
            Kirigami.FormData.label: i18n("Outline:")
            QQC2.CheckBox { checked: cfg_outline; onToggled: cfg_outline = checked }
            KQC.ColorButton { enabled: cfg_outline; color: cfg_outlineColor; onAccepted: cfg_outlineColor = color.toString() }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Shadow:")
            QQC2.ComboBox {
                model: [i18n("None"), i18n("Glow"), i18n("Drop shadow"), i18n("Pixel shadow")]
                currentIndex: cfg_shadowMode
                onActivated: cfg_shadowMode = currentIndex
            }
            KQC.ColorButton { enabled: cfg_shadowMode !== 0; color: cfg_shadowColor; onAccepted: cfg_shadowColor = color.toString() }
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Shadow strength:")
            enabled: cfg_shadowMode === 1 || cfg_shadowMode === 2
            value: cfg_shadowStrength
            onMoved: v => cfg_shadowStrength = v
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Backdrop") }

        RowLayout {
            Kirigami.FormData.label: i18n("Panel behind lyrics:")
            QQC2.CheckBox { checked: cfg_backdrop; onToggled: cfg_backdrop = checked }
            KQC.ColorButton { enabled: cfg_backdrop; color: cfg_backdropColor; onAccepted: cfg_backdropColor = color.toString() }
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Opacity:")
            enabled: cfg_backdrop
            value: cfg_backdropOpacity
            onMoved: v => cfg_backdropOpacity = v
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Corner radius:")
            enabled: cfg_backdrop
            from: 0; to: 100
            value: cfg_backdropRadius
            onValueModified: cfg_backdropRadius = value
        }
    }
}
