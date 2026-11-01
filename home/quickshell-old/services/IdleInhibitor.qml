import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property bool inhibited: !_hypridleActive
    property bool _hypridleActive: true

    function toggle() {
        _toggleProc.command = ["systemctl", "--user", _hypridleActive ? "stop" : "start", "hypridle.service"]
        _toggleProc.running = true
    }

    property Process _checkProc: Process {
        command: ["systemctl", "--user", "is-active", "hypridle.service"]
        running: false
        stdout: SplitParser {
            onRead: data => { root._hypridleActive = data.trim() === "active" }
        }
    }

    property Process _toggleProc: Process {
        running: false
        onExited: root._checkProc.running = true
    }

    property Timer _t: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._checkProc.running = true
    }
}
