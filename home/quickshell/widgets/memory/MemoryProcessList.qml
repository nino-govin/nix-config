import QtQuick
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    readonly property real largestKiB: MemoryService.processes.length > 0
        ? MemoryService.processes[0].rssKiB : 1

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
            text: "Top processes (RSS)"
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.labelSmall
        }

        Repeater {
            model: MemoryService.processes

            Item {
                required property var modelData

                width: column.width
                height: 24

                Rectangle {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    width: parent.width * parent.modelData.rssKiB / root.largestKiB
                    height: parent.height - 4
                    radius: Math.min(ShellMetrics.radiusMedium, width / 2)
                    color: Theme.withOpacity(Theme.accentColor, 0.12)
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        right: sizeText.left
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    text: parent.modelData.name
                        + (parent.modelData.count > 1 ? "  ×" + parent.modelData.count : "")
                    elide: Text.ElideRight
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: Typography.bodySmall
                }

                Text {
                    id: sizeText
                    anchors {
                        right: parent.right
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    text: MemoryService.format(parent.modelData.rssKiB)
                    color: Theme.secondaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: Typography.labelSmall
                }
            }
        }
    }
}
