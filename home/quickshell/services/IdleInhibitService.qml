pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool hypridleActive: true
    readonly property bool inhibited: !hypridleActive

    function toggle(): void {
        toggler.command = ["systemctl", "--user",
            hypridleActive ? "stop" : "start", "hypridle.service"];
        toggler.running = true;
    }

    Process {
        id: checker
        command: ["systemctl", "--user", "is-active", "hypridle.service"]
        stdout: StdioCollector {
            onStreamFinished: root.hypridleActive = text.trim() === "active"
        }
    }

    Process {
        id: toggler
        onExited: checker.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!checker.running) checker.running = true
    }
}
