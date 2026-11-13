import QtQuick
import QtQuick.Layouts
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
            rightMargin: 10
        }
        spacing: 2

        Text {
            text: "Local servers"
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.labelSmall
        }

        Repeater {
            model: DevService.servers

            Item {
                id: row

                required property var modelData

                width: column.width
                height: 34

                HoverHandler {
                    id: hover
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: Icons.server
                        color: Theme.accentColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 14
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.name
                            elide: Text.ElideRight
                            color: Theme.primaryTextColor
                            font.family: Typography.bodyFontFamily
                            font.pixelSize: Typography.bodySmall
                        }

                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.command + " · " + DevService.shortPath(row.modelData.directory)
                            elide: Text.ElideMiddle
                            color: Theme.mutedTextColor
                            font.family: Typography.bodyFontFamily
                            font.pixelSize: Typography.labelSmall - 1
                        }
                    }

                    DevPortChip {
                        port: row.modelData.port
                    }

                    DevIconButton {
                        opacity: hover.hovered ? 1 : 0
                        icon: Icons.stop
                        danger: true
                        onClicked: DevService.stopServer(row.modelData)
                    }
                }
            }
        }
    }
}
