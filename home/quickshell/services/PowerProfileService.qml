pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string dataHome: Quickshell.env("XDG_DATA_HOME")
        || Quickshell.env("HOME") + "/.local/share"
    readonly property string statePath: dataHome + "/power-profile"
    readonly property var modes: ["economy", "balanced", "performance"]
    property string mode: "balanced"
    property string pendingMode: ""
    readonly property bool applying: applier.running
    property int refreshMin: 0
    property int refreshMax: 0

    function setMode(next: string): void {
        if (applier.running || modes.indexOf(next) === -1)
            return;
        mode = next;
        pendingMode = next;
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

    FileView {
        path: root.dataHome + "/quickshell-host.json"
        printErrors: false
        onLoaded: {
            try {
                const refresh = JSON.parse(text()).refresh;
                root.refreshMin = refresh.min;
                root.refreshMax = refresh.max;
            } catch (error) {}
        }
    }

    Process {
        id: applier
        onExited: {
            root.pendingMode = "";
            HyprlandService.refreshMonitors();
        }
    }
}
