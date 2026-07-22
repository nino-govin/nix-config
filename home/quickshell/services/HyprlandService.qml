import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

QtObject {
    readonly property var    workspaces:      Hyprland.workspaces
    readonly property int    activeWorkspace: Hyprland.focusedWorkspace?.id ?? 1
    readonly property string activeTitle:     Hyprland.activeToplevel?.title ?? ""
    readonly property string keyboardLayout:  _layout

    property string _layout: "FR"

    property Connections _conn: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const parts = event.data.split(",")
                if (parts.length >= 2) {
                    const lang = parts[1].trim().toUpperCase()
                    _layout = lang.includes("FRENCH") || lang.includes("FR")  ? "FR"
                            : lang.includes("US") || lang.includes("ENGLISH") ? "EN"
                            : lang.substring(0, 2)
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
