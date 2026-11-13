import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property var container
    readonly property var stat: DevService.stats[container.id]
    readonly property color stateColor: !container.running ? Theme.mutedTextColor
        : container.health === "unhealthy" ? Theme.dangerColor
        : container.health === "starting" ? Theme.accentColor
        : Theme.successColor

    implicitHeight: 34

    HoverHandler {
        id: hover
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 8
            Layout.preferredHeight: 8
            radius: 4
            color: root.stateColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.container.label
                elide: Text.ElideRight
                color: root.container.running ? Theme.primaryTextColor : Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.bodySmall
            }

            Text {
                Layout.fillWidth: true
                text: root.container.status + (root.container.health !== "" ? " · " + root.container.health : "")
                elide: Text.ElideRight
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.labelSmall - 1
            }
        }

        Repeater {
            model: root.container.running ? root.container.ports : []

            DevPortChip {
                required property int modelData
                port: modelData
            }
        }

        Text {
            visible: !hover.hovered && root.stat !== undefined
            text: visible ? root.stat.cpu.toFixed(1) + "% · " + DevService.formatMemory(root.stat.memory) : ""
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.labelSmall
        }

        Row {
            visible: hover.hovered
            spacing: 2

            IconButton {
                icon: Icons.terminal
                onClicked: DevService.containerLogs(root.container)
            }

            IconButton {
                visible: root.container.running
                icon: Icons.restart
                onClicked: DevService.containerAction("restart", [root.container.id])
            }

            IconButton {
                icon: root.container.running ? Icons.stop : Icons.play
                danger: root.container.running
                onClicked: DevService.containerAction(root.container.running ? "stop" : "start", [root.container.id])
            }
        }
    }
}
