import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property string cfg_playerMode
    property int cfg_offsetMs
    property bool cfg_showWhenPaused
    property bool cfg_showTrackInfo

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Follow:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("Spotify only"), value: "spotify" },
                { text: i18n("Whatever is playing"), value: "any" }
            ]
            Component.onCompleted: currentIndex = indexOfValue(cfg_playerMode)
            onActivated: cfg_playerMode = currentValue
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Sync offset (ms):")
            from: -10000; to: 10000; stepSize: 50
            value: cfg_offsetMs
            onValueModified: cfg_offsetMs = value
        }
        QQC2.Label {
            text: i18n("Positive shows lines earlier, negative later.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Show:")
            text: i18n("Keep lyrics visible while paused")
            checked: cfg_showWhenPaused
            onToggled: cfg_showWhenPaused = checked
        }
        QQC2.CheckBox {
            text: i18n("Song title when there are no synced lyrics")
            checked: cfg_showTrackInfo
            onToggled: cfg_showTrackInfo = checked
        }

        QQC2.Label {
            Kirigami.FormData.label: i18n("Lyrics from:")
            text: "LRCLIB (lrclib.net)"
        }
    }
}
