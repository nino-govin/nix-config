import QtQuick
import QtQuick.Layouts
import "../../components/theme"

RowLayout {
    id: root

    required property var keys
    required property string label

    implicitHeight: 32
    spacing: 10

    Text {
        Layout.fillWidth: true
        text: root.label
        elide: Text.ElideRight
        color: Theme.secondaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: Typography.bodySmall
    }

    Row {
        spacing: 4

        Repeater {
            model: root.keys

            KeyCap {
                required property string modelData
                key: modelData
            }
        }
    }
}
