//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "./services"
import "./shell"

QtObject {
    id: root

    property bool _qsOpen: false
    property bool _pmOpen: false
    property bool _lchOpen: false
    property bool _wifiPopupOpen: false
    property bool _btPopupOpen:   false

    property HyprlandService hypr:    HyprlandService {}
    property Battery         battery: Battery {}
    property SysInfo         sysInfo: SysInfo {}
    property Network         network: Network {}
    property Clock           clock:   Clock {}
    property IdleInhibitor   idle:    IdleInhibitor {}
    property Audio           audio:   Audio {}
    property Brightness      brightness: Brightness {}
    property Bluetooth       bluetooth: Bluetooth {}
    property Media           media:    Media {}
    property Wifi            wifi:     Wifi {}

    property Rail rail: Rail {
        hyprland:  root.hypr
        battery:   root.battery
        sysInfo:   root.sysInfo
        idle:      root.idle
        qsVisible: root._qsOpen
        onQsToggled: v => { root._qsOpen = v }
    }

    property TopBar topbar: TopBar {
        clock:    root.clock
        network:  root.network
        hyprland: root.hypr
        audio:    root.audio
    }

    property QuickSettings qs: QuickSettings {
        open:       root._qsOpen
        battery:    root.battery
        network:    root.network
        audio:      root.audio
        brightness: root.brightness
        bluetooth:  root.bluetooth
        wifi:       root.wifi
        media:      root.media
        onPanelClosed:     root._qsOpen = false
        onOpenPowerMenu:   { root._qsOpen = false; root._pmOpen = true }
        onOpenWifiPopup:   root._wifiPopupOpen = true
        onOpenBtPopup:     root._btPopupOpen   = true
    }

    property WifiPopup wifiPopup: WifiPopup {
        open: root._wifiPopupOpen
        wifi: root.wifi
        onPanelClosed: root._wifiPopupOpen = false
    }

    property BluetoothPopup btPopup: BluetoothPopup {
        open: root._btPopupOpen
        bluetooth: root.bluetooth
        onPanelClosed: root._btPopupOpen = false
    }

    property PowerMenu pm: PowerMenu {
        open: root._pmOpen
        onPanelClosed: root._pmOpen = false
    }

    property NotificationCenter notifCenter: NotificationCenter {}

    property OSD osd: OSD {
        audio:      root.audio
        brightness: root.brightness
    }

    property Launcher launcher: Launcher {
        open: root._lchOpen
        onPanelClosed: root._lchOpen = false
    }

    property IpcHandler _ipc: IpcHandler {
        target: "showPowerMenu"
        function onSignalTriggered() { root._pmOpen = true }
    }

    property IpcHandler _ipcLauncher: IpcHandler {
        target: "launcher"
        function toggle() { root._lchOpen = !root._lchOpen }
        function show()   { root._lchOpen = true }
        function hide()   { root._lchOpen = false }
    }
}
