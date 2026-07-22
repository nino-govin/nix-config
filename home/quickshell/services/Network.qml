import QtQuick
import Quickshell.Io

QtObject {
    readonly property string ip:      _ip
    readonly property string ssid:    _ssid
    readonly property string downStr: _downStr
    readonly property string upStr:   _upStr

    property string _ip:      "—"
    property string _ssid:    "—"
    property string _downStr: "—"
    property string _upStr:   "—"
    property real   _prevRx:  0
    property real   _prevTx:  0

    property Process _ipProc: Process {
        command: ["bash", "-c",
            "ip -4 route get 1.1.1.1 2>/dev/null | awk '/src/{for(i=1;i<=NF;i++) if($i==\"src\") print $(i+1)}' | head -1 || echo '—'"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => { _ip = data.trim() }
        }
    }

    property Process _ssidProc: Process {
        command: ["bash", "-c", "iwgetid -r 2>/dev/null || echo '—'"]
        running: false
        stdout: SplitParser {
            onRead: data => { _ssid = data.trim() || "—" }
        }
    }

    property Process _bwProc: Process {
        command: ["bash", "-c",
            "iface=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '/dev/{for(i=1;i<=NF;i++) if($i==\"dev\") print $(i+1)}'); " +
            "[[ -z $iface ]] && echo '0 0' && exit; " +
            "rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0); " +
            "tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0); " +
            "echo \"$rx $tx\""
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(" ")
                const rx = parseFloat(parts[0]) || 0
                const tx = parseFloat(parts[1]) || 0
                if (_prevRx > 0) {
                    const dr = (rx - _prevRx) / 3
                    const dt = (tx - _prevTx) / 3
                    _downStr = _fmt(dr)
                    _upStr   = _fmt(dt)
                }
                _prevRx = rx
                _prevTx = tx
            }
        }
    }

    function _fmt(bps) {
        if (bps >= 1048576) return (bps / 1048576).toFixed(1) + "M"
        if (bps >= 1024)    return (bps / 1024).toFixed(0)    + "K"
        return bps.toFixed(0) + "B"
    }

    function _refresh() {
        _ipProc.running  = true
        _ssidProc.running = true
        _bwProc.running  = true
    }

    property Timer _t: Timer {
        interval: 3000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: _refresh()
    }
}
