pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string layoutName: ""
    readonly property string shortName: {
        const upper = layoutName.toUpperCase();
        if (upper.indexOf("FRENCH") !== -1)
            return "FR";
        if (upper.indexOf("ENGLISH") !== -1)
            return "US";
        return upper.substring(0, 2);
    }

    function cycle(): void {
        switcher.running = true;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (event.name !== "activelayout")
                return;
            const separator = event.data.indexOf(",");
            if (separator !== -1)
                root.layoutName = event.data.slice(separator + 1).trim();
        }
    }

    Process {
        id: reader
        running: true
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const keyboards = JSON.parse(text).keyboards || [];
                    const main = keyboards.find(keyboard => keyboard.main) || keyboards[0];
                    if (main)
                        root.layoutName = main.active_keymap;
                } catch (error) {
                    console.warn("KeyboardLayoutService: could not parse hyprctl devices:", error);
                }
            }
        }
    }

    Process {
        id: switcher
        command: ["hyprctl", "switchxkblayout", "all", "next"]
    }
}
