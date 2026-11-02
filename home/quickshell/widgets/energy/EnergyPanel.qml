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
    readonly property string gpuValue: !GpuPowerService.available ? "Unavailable"
        : !GpuPowerService.awake ? "Suspended"
        : GpuPowerService.inUse ? "Active" : "Idle, suspending"
    readonly property string gpuDetail: GpuPowerService.inUse
        ? GpuPowerService.clients.length + (GpuPowerService.clients.length === 1 ? " process" : " processes")
        : "Runtime PM " + GpuPowerService.status

    focus: OverlayState.energyVisible
    Keys.onEscapePressed: OverlayState.hideEnergy()

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

        EnergyBatteryHeader {
            Layout.fillWidth: true
        }

        PowerProfileSelector {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: Icons.batteryHealth
                label: "Health"
                value: BatteryService.healthPercent > 0
                    ? BatteryService.healthPercent.toFixed(1) + " %" : "Unknown"
                detail: BatteryService.capacityText
                    + (BatteryService.cycleCount > 0 ? " · " + BatteryService.cycleCount + " cycles" : "")
            }

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: Icons.display
                label: "Display"
                value: HyprlandService.refreshRate > 0 ? HyprlandService.refreshRate + " Hz" : "Unknown"
                detail: PowerProfileService.mode === "balanced" ? "Adaptive" : "Fixed"
            }

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: BatteryService.acOnline ? Icons.plug : Icons.battery
                label: "Source"
                value: BatteryService.acOnline ? "AC adapter" : "Battery"
                detail: BatteryService.status
            }

            StatTile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                icon: Icons.gpu
                label: "Dedicated GPU"
                value: root.gpuValue
                detail: root.gpuDetail
                highlighted: GpuPowerService.awake
            }
        }

        GpuClientList {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            visible: GpuPowerService.inUse
        }
    }

    Timer {
        interval: 2000
        running: OverlayState.energyVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: HyprlandService.refreshMonitors()
    }

    HoverHandler {
        id: energyHover
    }

    HoverDismissController {
        active: OverlayState.energyVisible
        panelHovered: energyHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hideEnergy()
    }
}
