import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property real value: _max > 0 ? _cur / _max : 0
    readonly property int  percent: Math.round(value * 100)
    readonly property string device: "intel_backlight"

    signal changed

    property int _cur: 0
    property int _max: 1

    property Process _readProc: Process {
        command: ["bash", "-c",
            "cur=$(cat /sys/class/backlight/intel_backlight/brightness 2>/dev/null || echo 0); " +
            "max=$(cat /sys/class/backlight/intel_backlight/max_brightness 2>/dev/null || echo 1); " +
            "echo \"$cur $max\""
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(" ")
                const nc = parseInt(p[0]) || 0
                const nm = parseInt(p[1]) || 1
                const wasChanged = nc !== _cur
                _cur = nc
                _max = nm
                if (wasChanged) root.changed()
            }
        }
    }

    property Process _setProc: Process {
        running: false
        onExited: root.refresh()
    }

    function setValue(v) {
        const pct = Math.max(1, Math.min(100, Math.round(v * 100)))
        _setProc.command = ["brightnessctl", "-q", "set", pct + "%"]
        _setProc.running = true
    }

    function refresh() {
        _readProc.running = true
    }

    property Timer _t: Timer {
        interval: 400
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
