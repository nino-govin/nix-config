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

    readonly property string cpuModel:   _cpuModel
    readonly property string cpuFreq:    _cpuFreq
    readonly property string cpuLoad:    _cpuLoad
    readonly property int    cpuCores:   _cpuCores
    readonly property string gpuName:    _gpuName
    readonly property string vramUsed:   _vramUsed
    readonly property string vramTotal:  _vramTotal
    readonly property string gpuPower:   _gpuPower
    readonly property string ramCached:  _ramCached
    readonly property string ramFree:    _ramFree
    readonly property string swapUsed:   _swapUsed
    readonly property string swapTotal:  _swapTotal
    readonly property string diskFree:   _diskFree
    readonly property string diskMount:  _diskMount

    property int    _cpuPct:   0
    property int    _gpuPct:   0
    property int    _ramPct:   0
    property string _cpuTemp:  "—"
    property string _gpuTemp:  "—"
    property string _ramUsed:  "—"
    property string _ramTotal: "—"
    property string _diskUsed:  "—"
    property string _diskTotal: "—"

    property string _cpuModel:  "—"
    property string _cpuFreq:   "—"
    property string _cpuLoad:   "—"
    property int    _cpuCores:  0
    property string _gpuName:   "—"
    property string _vramUsed:  "—"
    property string _vramTotal: "—"
    property string _gpuPower:  "—"
    property string _ramCached: "—"
    property string _ramFree:   "—"
    property string _swapUsed:  "—"
    property string _swapTotal: "—"
    property string _diskFree:  "—"
    property string _diskMount: "/"

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

    property Process _cpuMetaProc: Process {
        command: ["bash", "-c",
            "mdl=$(grep -m1 'model name' /proc/cpuinfo | sed 's/.*: //' | sed 's/  */ /g'); " +
            "cores=$(nproc); " +
            "freq=$(awk '/cpu MHz/{s+=$4;n++} END{if(n)printf \"%.2f GHz\",s/n/1000}' /proc/cpuinfo); " +
            "load=$(awk '{printf \"%s %s %s\",$1,$2,$3}' /proc/loadavg); " +
            "echo \"$mdl|$cores|$freq|$load\""
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _cpuModel = p[0] || "—"
                _cpuCores = parseInt(p[1]) || 0
                _cpuFreq  = p[2] || "—"
                _cpuLoad  = p[3] || "—"
            }
        }
    }

    property Process _gpuProc: Process {
        command: ["bash", "-c",
            "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,name,memory.used,memory.total,power.draw " +
            "--format=csv,noheader,nounits 2>/dev/null | " +
            "awk -F', ' '{printf \"%d|%s|%s|%s|%s|%s\",$1,$2,$3,$4,$5,$6}' || echo '0|—|—|—|—|—'"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _gpuPct   = parseInt(p[0]) || 0
                _gpuTemp  = (p[1] && p[1] !== "—") ? p[1] + "°C" : "—"
                _gpuName  = p[2] || "—"
                _vramUsed = (p[3] && p[3] !== "—") ? p[3] + " MiB" : "—"
                _vramTotal = (p[4] && p[4] !== "—") ? p[4] + " MiB" : "—"
                _gpuPower = (p[5] && p[5] !== "—") ? parseFloat(p[5]).toFixed(1) + "W" : "—"
            }
        }
    }

    property Process _ramProc: Process {
        command: ["bash", "-c",
            "free -b | awk '/^Mem:/{u=$3;t=$2;f=$4;c=$6; " +
            "  printf \"%d|%.1f|%.1f|%.1f|%.1f\", int(100*u/t), u/1073741824, t/1073741824, f/1073741824, c/1073741824}'"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _ramPct    = parseInt(p[0]) || 0
                _ramUsed   = (p[1] || "—") + "G"
                _ramTotal  = (p[2] || "—") + "G"
                _ramFree   = (p[3] || "—") + "G"
                _ramCached = (p[4] || "—") + "G"
            }
        }
    }

    property Process _swapProc: Process {
        command: ["bash", "-c",
            "free -b | awk '/^Swap:/{if($2>0)printf \"%.1fG|%.1fG\",$3/1073741824,$2/1073741824; else printf \"—|off\"}'"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _swapUsed  = p[0] || "—"
                _swapTotal = p[1] || "off"
            }
        }
    }

    property Process _diskProc: Process {
        command: ["bash", "-c", "df -h / | awk 'NR==2{printf \"%s|%s|%s|%s\",$3,$2,$4,$6}'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _diskUsed  = p[0] || "—"
                _diskTotal = p[1] || "—"
                _diskFree  = p[2] || "—"
                _diskMount = p[3] || "/"
            }
        }
    }

    function _refresh() {
        _cpuProc.running     = true
        _cpuTempProc.running = true
        _cpuMetaProc.running = true
        _gpuProc.running     = true
        _ramProc.running     = true
        _swapProc.running    = true
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
