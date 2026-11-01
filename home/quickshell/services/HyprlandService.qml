pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    readonly property bool available: true
    readonly property bool windowsReady: true

    readonly property var workspaces: Hyprland.workspaces.values
        .filter(workspace => workspace.id > 0)
        .sort((a, b) => a.id - b.id)
        .map(workspace => ({
            id: workspace.id,
            idx: workspace.id,
            name: workspace.name,
            output: workspace.monitor ? workspace.monitor.name : "",
            is_active: workspace.active,
            is_focused: workspace.focused,
            is_urgent: workspace.urgent
        }))

    readonly property var windows: Hyprland.toplevels.values
        .filter(toplevel => toplevel.workspace)
        .map(toplevel => ({
            id: toplevel.address,
            workspace_id: toplevel.workspace.id
        }))

    function focusWorkspace(id: int): void {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
    }

    function focusWindow(address: string): void {
        Hyprland.dispatch("hl.dsp.focus({ window = \"address:0x" + address + "\" })");
    }
}
