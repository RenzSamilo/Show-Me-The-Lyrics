import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory { name: i18n("General"); icon: "configure"; source: "config/General.qml" }
    ConfigCategory { name: i18n("Presets"); icon: "favorite"; source: "config/Presets.qml" }
    ConfigCategory { name: i18n("Style"); icon: "preferences-desktop-font"; source: "config/Style.qml" }
    ConfigCategory { name: i18n("Animation"); icon: "media-playback-start"; source: "config/Animation.qml" }
    ConfigCategory { name: i18n("Layout"); icon: "view-list-text"; source: "config/Layout.qml" }
    ConfigCategory { name: i18n("Overlay"); icon: "window-pin"; source: "config/Overlay.qml" }
}
