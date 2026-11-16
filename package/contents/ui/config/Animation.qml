import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQC

KCM.SimpleKCM {
    property int cfg_transition
    property int cfg_transitionMs
    property bool cfg_karaoke
    property string cfg_karaokeColor
    property bool cfg_wave
    property int cfg_waveAmplitude
    property int cfg_waveSpeed
    property int cfg_rainbowSpeed

    Kirigami.FormLayout {
        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Line change") }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Transition:")
            model: [i18n("None"), i18n("Scroll"), i18n("Fade"), i18n("Pop")]
            currentIndex: cfg_transition
            onActivated: cfg_transition = currentIndex
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Duration (ms):")
            enabled: cfg_transition !== 0
            from: 50; to: 2000; stepSize: 50
            value: cfg_transitionMs
            onValueModified: cfg_transitionMs = value
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Current line") }

        RowLayout {
            Kirigami.FormData.label: i18n("Karaoke fill:")
            QQC2.CheckBox { checked: cfg_karaoke; onToggled: cfg_karaoke = checked }
            KQC.ColorButton { enabled: cfg_karaoke; color: cfg_karaokeColor; onAccepted: cfg_karaokeColor = color.toString() }
        }
        QQC2.Label {
            text: i18n("Sweeps evenly across the line; the lyrics source has no per-word timing.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Wave:")
            checked: cfg_wave
            onToggled: cfg_wave = checked
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Wave height:")
            enabled: cfg_wave
            from: 1; to: 20; suffix: " px"
            value: cfg_waveAmplitude
            onMoved: v => cfg_waveAmplitude = v
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Wave speed:")
            enabled: cfg_wave
            from: 5; to: 200
            value: cfg_waveSpeed
            onMoved: v => cfg_waveSpeed = v
        }
        PercentSlider {
            Kirigami.FormData.label: i18n("Rainbow speed:")
            from: 0; to: 200
            value: cfg_rainbowSpeed
            onMoved: v => cfg_rainbowSpeed = v
        }
        QQC2.Label {
            text: i18n("Rainbow is a colour mode: pick it under Style → Current line.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }
    }
}
