import QtQuick
import Quickshell.Io

QtObject {
    readonly property int    cpuPercent: _cpuPct
    readonly property int    gpuPercent: _gpuPct
    readonly property int    ramPercent: _ramPct
    readonly property string cpuTemp:    _cpuTemp
    readonly property string gpuTemp:    _gpuTemp
    readonly property string ramUsed:    _ramUsed
    readonly property string ramTotal:   _ramTotal
    readonly property string diskUsed:   _diskUsed
    readonly property string diskTotal:  _diskTotal

    property int    _cpuPct:   0
    property int    _gpuPct:   0
    property int    _ramPct:   0
    property string _cpuTemp:  "—"
    property string _gpuTemp:  "—"
    property string _ramUsed:  "—"
    property string _ramTotal: "—"
    property string _diskUsed:  "—"
    property string _diskTotal: "—"

    property var _prevCpu: null

    property Process _cpuProc: Process {
        command: ["bash", "-c", "head -1 /proc/stat"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/).slice(1).map(Number)
                const idle  = parts[3]
                const total = parts.reduce((a, b) => a + b, 0)
                if (_prevCpu !== null) {
                    const di = idle  - _prevCpu.idle
                    const dt = total - _prevCpu.total
                    _cpuPct = dt > 0 ? Math.max(0, Math.round(100 * (1 - di / dt))) : _cpuPct
                }
                _prevCpu = { idle, total }
            }
        }
    }

    property Process _cpuTempProc: Process {
        command: ["bash", "-c",
            "for f in /sys/class/thermal/thermal_zone*/temp; do " +
            "  t=$(cat ${f%temp}type 2>/dev/null); " +
            "  case $t in *cpu*|*x86*|*pkg*) awk '{printf \"%d°C\",int($1/1000)}' $f; exit;; esac; " +
            "done; echo '—'"
        ]
        running: false
        stdout: SplitParser { onRead: data => { _cpuTemp = data.trim() } }
    }

    property Process _gpuProc: Process {
        command: ["bash", "-c",
            "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu " +
            "--format=csv,noheader,nounits 2>/dev/null | " +
            "awk -F', ' '{printf \"%d|%s%%\",$1,$2}' || echo '0|—'"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _gpuPct  = parseInt(p[0]) || 0
                _gpuTemp = (p[1] || "—").replace("%", "°C")
            }
        }
    }

    property Process _ramProc: Process {
        command: ["bash", "-c",
            "free -b | awk '/^Mem:/{u=$3;t=$2; printf \"%d|%.1f|%.1f\", int(100*u/t), u/1073741824, t/1073741824}'"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _ramPct   = parseInt(p[0]) || 0
                _ramUsed  = (p[1] || "—") + "G"
                _ramTotal = (p[2] || "—") + "G"
            }
        }
    }

    property Process _diskProc: Process {
        command: ["bash", "-c", "df -h / | awk 'NR==2{printf \"%s|%s\",$3,$2}'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _diskUsed  = p[0] || "—"
                _diskTotal = p[1] || "—"
            }
        }
    }

    function _refresh() {
        _cpuProc.running     = true
        _cpuTempProc.running = true
        _gpuProc.running     = true
        _ramProc.running     = true
        _diskProc.running    = true
    }

    property Timer _t: Timer {
        interval: 3000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: _refresh()
    }
}
