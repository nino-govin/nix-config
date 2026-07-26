import QtQuick
import Quickshell
import Quickshell.Io
import "./services"
import "./shell"

QtObject {
    id: root

    property bool _qsOpen: false
    property bool _pmOpen: false

    property HyprlandService hypr:    HyprlandService {}
    property Battery         battery: Battery {}
    property SysInfo         sysInfo: SysInfo {}
    property Network         network: Network {}
    property Clock           clock:   Clock {}

    property Rail rail: Rail {
        hyprland:  root.hypr
        battery:   root.battery
        sysInfo:   root.sysInfo
        qsVisible: root._qsOpen
        onQsToggled: v => { root._qsOpen = v }
    }

    property TopBar topbar: TopBar {
        clock:    root.clock
        network:  root.network
        hyprland: root.hypr
    }

    property QuickSettings qs: QuickSettings {
        open:    root._qsOpen
        battery: root.battery
        network: root.network
        onPanelClosed:   root._qsOpen = false
        onOpenPowerMenu: { root._qsOpen = false; root._pmOpen = true }
    }

    property PowerMenu pm: PowerMenu {
        open: root._pmOpen
        onPanelClosed: root._pmOpen = false
    }

    property NotificationCenter notifCenter: NotificationCenter {}

    property IpcHandler _ipc: IpcHandler {
        target: "showPowerMenu"
        function onSignalTriggered() { root._pmOpen = true }
    }
}
