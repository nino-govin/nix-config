pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import "../components/theme"

Singleton {
    id: root

    property bool enabled: false

    function hex(value: color, alpha: string): string {
        const channel = component => Math.round(component * 255).toString(16).padStart(2, "0");
        return channel(value.r) + channel(value.g) + channel(value.b) + alpha;
    }

    function exportTheme(): void {
        enabled = true;
        applier.command = ["hyprctl", "eval",
            "hl.config({ decoration = { shadow = { color = \"rgba("
            + hex(Theme.accentColor, "55") + ")\", color_inactive = \"rgba(00000040)\" } } })"];
        applier.running = true;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (root.enabled && event.name === "configreloaded")
                root.exportTheme();
        }
    }

    Process {
        id: applier
    }
}
