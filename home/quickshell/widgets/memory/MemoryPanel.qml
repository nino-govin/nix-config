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
    readonly property real desiredHeight: topPadding + content.implicitHeight + bottomPadding

    focus: OverlayState.memoryVisible
    Keys.onEscapePressed: OverlayState.hideMemory()

    ColumnLayout {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: root.topPadding
            leftMargin: 18
            rightMargin: 18
        }
        spacing: 14

        MemoryGaugeHeader {
            Layout.fillWidth: true
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: Icons.cache
                label: "Cache"
                value: MemoryService.format(MemoryService.reclaimableKiB)
                detail: "Freed on demand"
            }

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: Icons.pressure
                label: "Pressure"
                value: MemoryService.pressureLevel
                detail: "some " + MemoryService.pressureSome.toFixed(1)
                    + "% · full " + MemoryService.pressureFull.toFixed(1) + "%"
                highlighted: MemoryService.pressureLevel !== "None"
            }

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: Icons.sharedMemory
                label: "Shared"
                value: MemoryService.format(MemoryService.sharedKiB)
                detail: "tmpfs and shm"
            }

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: Icons.dirtyMemory
                label: "Dirty"
                value: MemoryService.format(MemoryService.dirtyKiB)
                detail: "Pending disk write"
            }
        }

        MemoryProcessList {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            visible: MemoryService.processes.length > 0
        }
    }

    Timer {
        interval: 2000
        running: OverlayState.memoryVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: MemoryService.refreshDetails()
    }

    HoverHandler {
        id: memoryHover
    }

    HoverDismissController {
        active: OverlayState.memoryVisible
        panelHovered: memoryHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hideMemory()
    }
}
