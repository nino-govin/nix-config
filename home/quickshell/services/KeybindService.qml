pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var categories: []

    readonly property var modifierBits: [
        { bit: 64, label: "SUPER" },
        { bit: 4, label: "CTRL" },
        { bit: 8, label: "ALT" },
        { bit: 1, label: "SHIFT" }
    ]
    readonly property var keyLabels: ({
        ampersand: "&", eacute: "é", quotedbl: "\"", apostrophe: "'",
        parenleft: "(", parenright: ")", minus: "-", egrave: "è",
        underscore: "_", ccedilla: "ç", agrave: "à", equal: "=",
        Return: "⏎", space: "Space", Tab: "Tab", Escape: "Esc",
        left: "←", right: "→", up: "↑", down: "↓",
        "mouse:272": "LMB", "mouse:273": "RMB", "mouse:274": "MMB",
        mouse_down: "Scroll ↓", mouse_up: "Scroll ↑"
    })

    function reload(): void {
        if (!reader.running)
            reader.running = true;
    }

    function keyLabel(key: string): string {
        if (keyLabels[key] !== undefined)
            return keyLabels[key];
        if (key.startsWith("XF86"))
            return key.slice(4).replace(/([a-z])([A-Z])/g, "$1 $2");
        return key.length === 1 ? key.toUpperCase() : key;
    }

    function parse(text: string): void {
        let binds;
        try {
            binds = JSON.parse(text);
        } catch (error) {
            return;
        }

        const result = [];
        const byName = {};
        for (const bind of binds) {
            if (!bind.has_description || !bind.description)
                continue;
            const separator = bind.description.indexOf(":");
            const category = separator > 0 ? bind.description.slice(0, separator).trim() : "General";
            const label = separator > 0 ? bind.description.slice(separator + 1).trim() : bind.description;
            const modifiers = modifierBits.filter(item => bind.modmask & item.bit).map(item => item.label);
            const key = keyLabel(bind.key);

            if (!byName[category]) {
                byName[category] = { name: category, binds: [], ranges: {} };
                result.push(byName[category]);
            }
            const group = byName[category];
            const numbered = label.match(/^(.*\S)\s+(\d+)$/);
            if (numbered) {
                const rangeKey = numbered[1] + "|" + modifiers.join("+");
                const range = group.ranges[rangeKey];
                if (range) {
                    range.last = Number(numbered[2]);
                    range.lastKey = key;
                    range.entry.label = numbered[1] + " " + range.first + "–" + range.last;
                    range.entry.keys = modifiers.concat([range.firstKey + " … " + key]);
                    continue;
                }
                const entry = { keys: modifiers.concat([key]), label: label };
                group.ranges[rangeKey] = {
                    first: Number(numbered[2]), last: Number(numbered[2]),
                    firstKey: key, lastKey: key, entry: entry
                };
                group.binds.push(entry);
                continue;
            }
            group.binds.push({ keys: modifiers.concat([key]), label: label });
        }

        categories = result.map(group => ({ name: group.name, binds: group.binds }));
    }

    Process {
        id: reader
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "configreloaded")
                root.reload();
        }
    }

    Component.onCompleted: reload()
}
