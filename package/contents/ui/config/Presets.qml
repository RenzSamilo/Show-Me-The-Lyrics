import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import ".." as Ui
import "../../code/style.js" as Style

// Presets write straight to the widget's config, so they apply on click (no Apply needed).
KCM.SimpleKCM {
    id: page

    // keys a preview needs that a preset doesn't store
    readonly property var previewLayout: ({ fontSize: 24, alignment: 1, wrap: false, inactiveScale: 70, inactiveOpacity: 45 })
    readonly property var userPresets: Style.parseList(Plasmoid.configuration.userPresets)
    readonly property bool shuffle: Plasmoid.configuration.shuffleEnabled
    readonly property var pool: Style.parseList(Plasmoid.configuration.shufflePool)   // preset names
    property string appliedName: ""

    function save(key, value) {
        Plasmoid.configuration[key] = value;
        Plasmoid.configuration.writeConfig();  // keep it even if the dialog is cancelled
    }
    function apply(preset) {
        var style = Style.resolve(preset.style);
        Object.keys(style).forEach(function (k) { Plasmoid.configuration[k] = style[k]; });
        Plasmoid.configuration.writeConfig();
        appliedName = preset.name;
    }
    function saveCurrent(name) {
        var list = userPresets.filter(function (p) { return p.name !== name; });
        list.push({ name: name, style: Style.capture(Plasmoid.configuration) });
        save("userPresets", JSON.stringify(list));
    }
    function remove(name) {
        save("userPresets", JSON.stringify(userPresets.filter(function (p) { return p.name !== name; })));
        setInPool(name, false);
    }
    function setInPool(name, on) {
        var list = pool.filter(function (n) { return n !== name; });
        if (on) list.push(name);
        save("shufflePool", JSON.stringify(list));
    }

    Ui.Fonts {}

    // one shared clock and sweep for every preview card
    FrameAnimation { id: clock; running: page.visible }
    property real sweep: 0
    NumberAnimation on sweep { from: 0; to: 1.3; duration: 3500; loops: Animation.Infinite; running: page.visible }

    component Card: QQC2.AbstractButton {
        id: card
        required property var preset
        property bool removable: false

        Layout.fillWidth: true
        implicitHeight: Kirigami.Units.gridUnit * 4
        onClicked: page.apply(preset)
        Accessible.name: preset.name

        background: Rectangle {
            // fixed dark backing so light and glowing styles read the same in any colour scheme
            color: "#16161c"
            radius: Kirigami.Units.cornerRadius
            border.width: card.visualFocus || card.hovered || page.appliedName === card.preset.name ? 2 : 1
            border.color: page.appliedName === card.preset.name ? Kirigami.Theme.highlightColor
                : card.hovered || card.visualFocus ? Kirigami.Theme.hoverColor : "#33333d"
        }
        contentItem: Item {
            Ui.LyricLine {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                cfg: Object.assign({}, page.previewLayout, Style.resolve(card.preset.style))
                text: card.preset.name
                active: true
                progress: Math.min(1, page.sweep)
                fxTime: clock.elapsedTime
            }
            QQC2.CheckBox {
                visible: page.shuffle
                anchors { left: parent.left; top: parent.top }
                checked: page.pool.indexOf(card.preset.name) >= 0
                onToggled: page.setInPool(card.preset.name, checked)
                Accessible.name: i18n("Include %1 in shuffle", card.preset.name)
                QQC2.ToolTip.text: i18n("Include in shuffle")
                QQC2.ToolTip.visible: hovered
            }
            QQC2.ToolButton {
                visible: card.removable
                anchors { right: parent.right; top: parent.top }
                icon.name: "edit-delete"
                text: i18n("Delete preset")
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.text: text
                QQC2.ToolTip.visible: hovered
                onClicked: page.remove(card.preset.name)
            }
        }
    }

    component CardGrid: GridLayout {
        id: cardGrid
        property var presets: []
        property bool removable: false
        Layout.fillWidth: true
        columns: Math.max(1, Math.floor(page.width / (Kirigami.Units.gridUnit * 14)))
        columnSpacing: Kirigami.Units.smallSpacing
        rowSpacing: Kirigami.Units.smallSpacing
        uniformCellWidths: true
        Repeater {
            model: cardGrid.presets
            Card { required property var modelData; preset: modelData; removable: cardGrid.removable }
        }
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: i18n("Click a preset to apply it. Presets change style and animation; size, layout and overlay stay as they are.")
        }

        QQC2.CheckBox {
            text: i18n("Shuffle: a random preset on every line")
            checked: page.shuffle
            onToggled: page.save("shuffleEnabled", checked)
        }
        QQC2.Label {
            visible: page.shuffle
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: page.pool.length > 0
                ? i18np("Shuffling between %1 ticked preset.", "Shuffling between %1 ticked presets.", page.pool.length)
                : i18n("Tick the presets to shuffle between. Until you tick one, your normal style is used.")
        }

        CardGrid { presets: Style.builtin.filter(p => !p.group) }

        Kirigami.Heading { level: 4; text: i18n("Minecraft") }
        CardGrid { presets: Style.builtin.filter(p => p.group === "Minecraft") }

        Kirigami.Heading { level: 4; text: i18n("Yours"); visible: page.userPresets.length > 0 }
        CardGrid { presets: page.userPresets; removable: true; visible: page.userPresets.length > 0 }

        Kirigami.Separator { Layout.fillWidth: true }

        RowLayout {
            Layout.fillWidth: true
            QQC2.TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: i18n("Name for your current style")
                onAccepted: saveButton.clicked()
            }
            QQC2.Button {
                id: saveButton
                text: i18n("Save as Preset")
                icon.name: "document-save"
                enabled: nameField.text.trim() !== ""
                onClicked: { page.saveCurrent(nameField.text.trim()); nameField.clear(); }
            }
        }
        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            text: i18n("Saves the style that is applied right now. Press Apply first if you changed other pages.")
        }
    }
}
