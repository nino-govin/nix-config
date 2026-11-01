import QtQuick
import Quickshell.Io

QtObject {
    readonly property string mode: _mode

    property string _mode: "balanced"

    property Process _readProc: Process {
        command: ["bash", "-c", "cat \"${XDG_DATA_HOME:-$HOME/.local/share}/power-profile\" 2>/dev/null || echo balanced"]
        running: true
        stdout: SplitParser {
            onRead: data => { _mode = data.trim() }
        }
    }

    property Process _applyProc: Process {
        running: false
        stdout: SplitParser { onRead: _ => {} }
        stderr: SplitParser { onRead: _ => {} }
    }

    function setMode(m) {
        _mode = m
        _applyProc.command = ["bash", "-c", `~/.local/bin/set-power-profile ${m}`]
        _applyProc.running = true
    }
}
