import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    required property var project
    readonly property bool expanded: DevService.isExpanded(project)
    readonly property var runningIds: project.containers.filter(container => container.running).map(container => container.id)

    implicitHeight: column.implicitHeight + 16
    radius: ShellMetrics.radiusLarge
    color: Theme.panelSurfaceColor
    clip: true

    Behavior on implicitHeight {
        MotionAnimation { type: MotionAnimation.FastSpatial }
    }

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 8
            leftMargin: 14
            rightMargin: 10
        }

        Item {
            width: parent.width
            height: 34

            HoverHandler {
                id: headerHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: DevService.toggleProject(root.project)
            }

            RowLayout {
                anchors.fill: parent
                spacing: 8

                Text {
                    text: root.expanded ? Icons.chevronDown : Icons.chevronRight
                    color: Theme.mutedTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                }

                Text {
                    text: root.project.name !== "" ? root.project.name : "Containers"
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: Typography.bodyMedium
                    font.weight: Font.Medium
                }

                Rectangle {
                    implicitWidth: countText.implicitWidth + 12
                    implicitHeight: 18
                    radius: height / 2
                    color: root.project.running > 0 ? Theme.withOpacity(Theme.successColor, 0.18) : Theme.selectedSurfaceColor

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: root.project.running + "/" + root.project.containers.length
                        color: root.project.running > 0 ? Theme.successColor : Theme.mutedTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: Typography.labelSmall
                        font.weight: Font.Medium
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    visible: !headerHover.hovered && root.project.hasStats
                    text: visible ? root.project.cpu.toFixed(1) + "% · " + DevService.formatMemory(root.project.memory) : ""
                    color: Theme.secondaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: Typography.labelSmall
                }

                Row {
                    visible: headerHover.hovered
                    spacing: 2

                    DevIconButton {
                        visible: root.project.name !== ""
                        icon: Icons.terminal
                        onClicked: DevService.projectLogs(root.project)
                    }

                    DevIconButton {
                        visible: root.project.running > 0
                        icon: Icons.restart
                        onClicked: DevService.containerAction("restart", root.runningIds)
                    }

                    DevIconButton {
                        icon: root.project.running > 0 ? Icons.stop : Icons.play
                        danger: root.project.running > 0
                        onClicked: DevService.containerAction(root.project.running > 0 ? "stop" : "start",
                            root.project.running > 0 ? root.runningIds : root.project.containers.map(container => container.id))
                    }
                }
            }
        }

        Repeater {
            model: root.expanded ? root.project.containers : []

            DevContainerRow {
                required property var modelData
                width: column.width
                container: modelData
            }
        }
    }
}
