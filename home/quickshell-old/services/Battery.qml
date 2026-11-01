import QtQuick
import Quickshell.Io

QtObject {
    readonly property int     percent:      _percent
    readonly property bool    charging:     _charging
    readonly property string  label:        _percent + "%"
    readonly property string  timeStr:      _timeStr
    readonly property string  powerStr:     _powerStr
    readonly property int     cycles:       _cycles
    readonly property int     healthPct:    _healthPct
    readonly property string  model:        _model
    readonly property string  status:       _status

    property int    _percent:   0
    property bool   _charging:  false
    property string _timeStr:   "—"
    property string _powerStr:  "—"
    property int    _cycles:    0
    property int    _healthPct: 0
    property string _model:     "—"
    property string _status:    "Unknown"

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
            onRead: data => {
                _status   = data.trim()
                _charging = _status === "Charging"
            }
        }
    }

    property Process _detailProc: Process {
        command: ["bash", "-c",
            "b=/sys/class/power_supply/BAT1; " +
            "cn=$(cat $b/charge_now 2>/dev/null || echo 0); " +
            "cf=$(cat $b/charge_full 2>/dev/null || echo 0); " +
            "cfd=$(cat $b/charge_full_design 2>/dev/null || echo 0); " +
            "cur=$(cat $b/current_now 2>/dev/null || echo 0); " +
            "volt=$(cat $b/voltage_now 2>/dev/null || echo 0); " +
            "cyc=$(cat $b/cycle_count 2>/dev/null || echo 0); " +
            "mdl=$(cat $b/model_name 2>/dev/null || echo unknown); " +
            "echo \"$cn|$cf|$cfd|$cur|$volt|$cyc|$mdl\""
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                const cn = parseFloat(p[0]) || 0
                const cf = parseFloat(p[1]) || 0
                const cfd = parseFloat(p[2]) || 0
                const cur = parseFloat(p[3]) || 0
                const volt = parseFloat(p[4]) / 1e6 || 0
                _cycles    = parseInt(p[5]) || 0
                _model     = p[6] || "—"
                _healthPct = cfd > 0 ? Math.round(100 * cf / cfd) : 0

                const watts = (cur / 1e6) * volt
                _powerStr = watts > 0 ? watts.toFixed(1) + "W" : "—"

                if (cur > 0) {
                    let hours = 0
                    if (_status === "Discharging") hours = cn / cur
                    else if (_status === "Charging") hours = (cf - cn) / cur
                    if (hours > 0) {
                        const h = Math.floor(hours)
                        const m = Math.round((hours - h) * 60)
                        _timeStr = h + "h" + (m < 10 ? "0" : "") + m
                    } else _timeStr = "—"
                } else _timeStr = "—"
            }
        }
    }

    function _refresh() {
        _capProc.running    = true
        _statProc.running   = true
        _detailProc.running = true
    }

    property Timer _t: Timer {
        interval: 30000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: _refresh()
    }
}
