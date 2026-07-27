import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

QtObject {
    readonly property var    workspaces:      Hyprland.workspaces
    readonly property int    activeWorkspace: Hyprland.focusedWorkspace?.id ?? 1
    readonly property string activeTitle:     Hyprland.activeToplevel?.title ?? ""
    readonly property string activeClass:     Hyprland.activeToplevel?.wmClass ?? ""
    readonly property string keyboardLayout:  _layout
    readonly property string keyboardLayoutFull: _layoutFull

    property string _layout: "FR"
    property string _layoutFull: "French (AZERTY)"

    property Connections _conn: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const parts = event.data.split(",")
                if (parts.length >= 2) {
                    const lang = parts[1].trim()
                    const u = lang.toUpperCase()
                    _layout = u.includes("FRENCH") || u.includes("FR")  ? "FR"
                            : u.includes("US") || u.includes("ENGLISH") ? "EN"
                            : u.substring(0, 2)
                    _layoutFull = lang
                }
            }
        }
    }

    property Process _wsDsp: Process { running: false }

    function focusWorkspace(id) {
        _wsDsp.command = ["hyprctl", "dispatch", "workspace", id.toString()]
        _wsDsp.running = true
    }
}
