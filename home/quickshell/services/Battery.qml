import QtQuick
import Quickshell.Io

QtObject {
    readonly property int     percent:  _percent
    readonly property bool    charging: _charging
    readonly property string  label:    _percent + "%"

    property int  _percent:  0
    property bool _charging: false

    property Process _capProc: Process {
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 0"]
        running: false
        stdout: SplitParser {
            onRead: data => { _percent = parseInt(data.trim()) || 0 }
        }
    }

    property Process _statProc: Process {
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo Unknown"]
        running: false
        stdout: SplitParser {
            onRead: data => { _charging = data.trim() === "Charging" }
        }
    }

    function _refresh() {
        _capProc.running  = true
        _statProc.running = true
    }

    property Timer _t: Timer {
        interval: 30000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: _refresh()
    }
}
