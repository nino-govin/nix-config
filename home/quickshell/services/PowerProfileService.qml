pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string statePath: (Quickshell.env("XDG_DATA_HOME")
        || Quickshell.env("HOME") + "/.local/share") + "/power-profile"
    readonly property var modes: ["economy", "balanced", "performance"]
    property string mode: "balanced"

    function setMode(next: string): void {
        if (applier.running)
            return;
        mode = next;
        applier.command = [Quickshell.env("HOME") + "/.local/bin/set-power-profile", next];
        applier.running = true;
    }

    function cycle(): void {
        setMode(modes[(modes.indexOf(mode) + 1) % modes.length]);
    }

    FileView {
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const value = text().trim();
            if (root.modes.indexOf(value) !== -1)
                root.mode = value;
        }
    }

    Process {
        id: applier
    }
}
