import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    readonly property real topPadding: ShellMetrics.panelScreenEdgeOverlap + 24
    readonly property real bottomPadding: 18
    readonly property real desiredHeight: topPadding + header.implicitHeight + 14 + list.implicitHeight + bottomPadding
    readonly property int containerCount: DevService.runningContainers.length
    readonly property int serverCount: DevService.servers.length
    readonly property string summary: {
        const parts = [];
        if (containerCount > 0)
            parts.push(containerCount + (containerCount === 1 ? " container" : " containers"));
        if (serverCount > 0)
            parts.push(serverCount + (serverCount === 1 ? " server" : " servers"));
        return parts.length > 0 ? parts.join(" · ") : "Nothing running";
    }
    readonly property string detail: !DevService.dockerAvailable ? "Docker unavailable"
        : containerCount > 0 && Object.keys(DevService.stats).length > 0
            ? DevService.totalCpu.toFixed(1) + "% CPU · " + DevService.formatMemory(DevService.totalMemory)
            : containerCount > 0 ? "Measuring usage…" : "Docker idle"

    focus: OverlayState.devVisible
    Keys.onEscapePressed: OverlayState.hideDev()

    Binding {
        target: DevService
        property: "detailed"
        value: OverlayState.devVisible
    }

    RowLayout {
        id: header

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: root.topPadding
            leftMargin: 18
            rightMargin: 18
        }
        spacing: 16

        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            radius: ShellMetrics.radiusLarge
            color: root.containerCount + root.serverCount > 0 ? Theme.accentColor : Theme.selectedSurfaceColor

            Behavior on color {
                MotionColorAnimation { type: MotionAnimation.FastEffects }
            }

            Text {
                anchors.centerIn: parent
                text: Icons.docker
                color: root.containerCount + root.serverCount > 0 ? Theme.accentTextColor : Theme.accentColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 28
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.summary
                elide: Text.ElideRight
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.titleLarge
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                text: root.detail
                elide: Text.ElideRight
                color: Theme.secondaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.bodySmall
            }
        }
    }

    Flickable {
        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
            topMargin: 14
            leftMargin: 18
            rightMargin: 18
            bottomMargin: root.bottomPadding
        }
        contentHeight: list.implicitHeight
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Column {
            id: list

            width: parent.width
            spacing: 10

            DevServerList {
                width: parent.width
                visible: DevService.servers.length > 0
            }

            Repeater {
                model: DevService.projects

                DevProjectCard {
                    required property var modelData
                    width: list.width
                    project: modelData
                }
            }
        }
    }

    HoverHandler {
        id: devHover
    }

    HoverDismissController {
        active: OverlayState.devVisible
        panelHovered: devHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hideDev()
    }
}
