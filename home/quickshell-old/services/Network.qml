import QtQuick
import Quickshell.Io

QtObject {
    readonly property string ip:        _ip
    readonly property string ssid:      _ssid
    readonly property string downStr:   _downStr
    readonly property string upStr:     _upStr
    readonly property string iface:     _iface
    readonly property string gateway:   _gateway
    readonly property string dns:       _dns
    readonly property string totalRxStr: _totalRxStr
    readonly property string totalTxStr: _totalTxStr

    property string _ip:        "—"
    property string _ssid:      "—"
    property string _downStr:   "—"
    property string _upStr:     "—"
    property string _iface:     "—"
    property string _gateway:   "—"
    property string _dns:       "—"
    property string _totalRxStr: "—"
    property string _totalTxStr: "—"
    property real   _prevRx:    0
    property real   _prevTx:    0

    property Process _ipProc: Process {
        command: ["bash", "-c",
            "r=$(ip -4 route get 1.1.1.1 2>/dev/null); " +
            "ip=$(echo \"$r\" | awk '/src/{for(i=1;i<=NF;i++) if($i==\"src\") print $(i+1)}' | head -1); " +
            "if=$(echo \"$r\" | awk '/dev/{for(i=1;i<=NF;i++) if($i==\"dev\") print $(i+1)}' | head -1); " +
            "gw=$(echo \"$r\" | awk '/via/{for(i=1;i<=NF;i++) if($i==\"via\") print $(i+1)}' | head -1); " +
            "echo \"${ip:-—}|${if:-—}|${gw:-—}\""
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split("|")
                _ip      = p[0] || "—"
                _iface   = p[1] || "—"
                _gateway = p[2] || "—"
            }
        }
    }

    property Process _ssidProc: Process {
        command: ["bash", "-c", "iwgetid -r 2>/dev/null || echo '—'"]
        running: false
        stdout: SplitParser {
            onRead: data => { _ssid = data.trim() || "—" }
        }
    }

    property Process _dnsProc: Process {
        command: ["bash", "-c",
            "resolvectl status 2>/dev/null | awk '/Current DNS Server:/{print $4;exit}' || " +
            "grep -m1 '^nameserver' /etc/resolv.conf | awk '{print $2}' || echo '—'"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => { _dns = data.trim() || "—" }
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
                _totalRxStr = _fmtTotal(rx)
                _totalTxStr = _fmtTotal(tx)
            }
        }
    }

    function _fmt(bps) {
        if (bps >= 1048576) return (bps / 1048576).toFixed(1) + "M"
        if (bps >= 1024)    return (bps / 1024).toFixed(0)    + "K"
        return bps.toFixed(0) + "B"
    }

    function _fmtTotal(bytes) {
        if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(2) + " GiB"
        if (bytes >= 1048576)    return (bytes / 1048576).toFixed(1)    + " MiB"
        if (bytes >= 1024)       return (bytes / 1024).toFixed(0)       + " KiB"
        return bytes.toFixed(0) + " B"
    }

    function _refresh() {
        _ipProc.running  = true
        _ssidProc.running = true
        _dnsProc.running = true
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
