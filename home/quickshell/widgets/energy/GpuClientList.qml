import QtQuick
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    implicitHeight: column.implicitHeight + 20
    radius: ShellMetrics.radiusLarge
    color: Theme.panelSurfaceColor

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
            leftMargin: 14
            rightMargin: 14
        }
        spacing: 4

        Text {
            text: "Holding the dGPU awake"
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.labelSmall
        }

        Repeater {
            model: GpuPowerService.clients

            Item {
                required property var modelData
                width: column.width
                height: 22

                Text {
                    anchors {
                        left: parent.left
                        right: pidText.left
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    text: parent.modelData.name
                    elide: Text.ElideRight
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: Typography.bodySmall
                }

                Text {
                    id: pidText
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    text: parent.modelData.pid
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: Typography.labelSmall
                }
            }
        }
    }
}
