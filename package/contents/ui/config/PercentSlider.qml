import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

// Integer slider with its value shown next to it.
RowLayout {
    id: row
    property int value
    property int from: 0
    property int to: 100
    property string suffix: "%"
    signal moved(int value)

    QQC2.Slider {
        Layout.preferredWidth: 200
        from: row.from; to: row.to; stepSize: 1
        value: row.value
        onMoved: row.moved(Math.round(value))
    }
    QQC2.Label { text: row.value + row.suffix }
}
