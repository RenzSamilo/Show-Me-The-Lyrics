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
    property var userPresets: parse(Plasmoid.configuration.userPresets)
    property string appliedName: ""

    function parse(json) {
        try { var list = JSON.parse(json); return Array.isArray(list) ? list : []; } catch (e) { return []; }
    }
    function apply(preset) {
        var style = Style.resolve(preset.style);
        Object.keys(style).forEach(function (k) { Plasmoid.configuration[k] = style[k]; });
        Plasmoid.configuration.writeConfig();  // keep it even if the dialog is cancelled
        appliedName = preset.name;
    }
    function saveCurrent(name) {
        var list = userPresets.filter(function (p) { return p.name !== name; });
        list.push({ name: name, style: Style.capture(Plasmoid.configuration) });
        Plasmoid.configuration.userPresets = JSON.stringify(list);
        Plasmoid.configuration.writeConfig();
    }
    function remove(name) {
        Plasmoid.configuration.userPresets = JSON.stringify(userPresets.filter(function (p) { return p.name !== name; }));
        Plasmoid.configuration.writeConfig();
    }

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

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: i18n("Click a preset to apply it. Presets change style and animation; size, layout and overlay stay as they are.")
        }

        GridLayout {
            Layout.fillWidth: true
            columns: Math.max(1, Math.floor(page.width / (Kirigami.Units.gridUnit * 14)))
            columnSpacing: Kirigami.Units.smallSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            uniformCellWidths: true

            Repeater {
                model: Style.builtin
                Card { required property var modelData; preset: modelData }
            }
            Repeater {
                model: page.userPresets
                Card { required property var modelData; preset: modelData; removable: true }
            }
        }

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
