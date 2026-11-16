import QtQuick

// Loads the fonts shipped in contents/fonts so they can be used by family name.
// Instantiate once wherever bundled fonts may be drawn (widget, settings previews).
Item {
    visible: false
    // families to offer in the font picker even if the system doesn't have them
    readonly property var families: ["Monocraft"]

    FontLoader { source: Qt.resolvedUrl("../fonts/Monocraft.ttf") }
    FontLoader { source: Qt.resolvedUrl("../fonts/Monocraft-Bold.ttf") }
}
