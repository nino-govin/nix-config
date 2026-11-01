import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property bool available: _available
    readonly property bool powered:   _powered
    readonly property string adapter: _adapter
    readonly property int connectedCount: _connectedCount
    readonly property var devices: _devices
    readonly property bool scanning: _scanning

    signal changed

    property bool   _available: false
    property bool   _powered:   false
    property string _adapter:   "hci0"
    property int    _connectedCount: 0
    property var    _devices:   []
    property bool   _scanning:  false

    property Process _statusProc: Process {
        command: ["bash", "-c",
            "if ! command -v bluetoothctl >/dev/null 2>&1; then echo 'na'; exit; fi; " +
            "pw=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2;exit}'); " +
            "cn=$(bluetoothctl devices Connected 2>/dev/null | wc -l); " +
            "echo \"${pw:-no}|${cn:-0}\""
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim()
                if (s === "na") {
                    if (root._available) { root._available = false; root.changed() }
                    return
                }
                const p = s.split("|")
                const powered = p[0] === "yes"
                const count   = parseInt(p[1]) || 0
                let ch = false
                if (!root._available) { root._available = true; ch = true }
                if (root._powered !== powered) { root._powered = powered; ch = true }
                if (root._connectedCount !== count) { root._connectedCount = count; ch = true }
                if (ch) root.changed()
            }
        }
    }

    property Process _devicesProc: Process {
        command: ["bash", "-c",
            "if ! command -v bluetoothctl >/dev/null 2>&1; then exit; fi; " +
            "connected=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}'); " +
            "paired=$(bluetoothctl devices Paired 2>/dev/null); " +
            "all=$(bluetoothctl devices 2>/dev/null); " +
            "echo \"$all\" | while read _ mac name; do " +
            "  [ -z \"$mac\" ] && continue; " +
            "  echo \"$connected\" | grep -q \"^$mac$\" && st=connected || st=known; " +
            "  echo \"$paired\" | grep -q \"$mac\" && p=1 || p=0; " +
            "  echo \"$mac|$name|$st|$p\"; " +
            "done"
        ]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const arr = []
                const lines = text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const p = lines[i].split("|")
                    if (p.length < 4 || p[0] === "") continue
                    arr.push({
                        mac:       p[0],
                        name:      p[1] || p[0],
                        connected: p[2] === "connected",
                        paired:    p[3] === "1"
                    })
                }
                arr.sort((a, b) => (b.connected ? 1 : 0) - (a.connected ? 1 : 0))
                root._devices = arr
                root.changed()
            }
        }
    }

    property Process _scanProc: Process {
        command: ["bash", "-c", "timeout 8 bluetoothctl --timeout 8 scan on >/dev/null 2>&1; exit 0"]
        running: false
        onExited: {
            root._scanning = false
            root.refresh()
        }
    }

    property Process _setProc: Process {
        running: false
        onExited: root.refresh()
    }

    function refresh() {
        _statusProc.running = true
        _devicesProc.running = true
    }

    function togglePower() {
        _setProc.command = ["bash", "-c", "bluetoothctl power " + (_powered ? "off" : "on") + " >/dev/null 2>&1"]
        _setProc.running = true
    }

    function setPower(on) {
        _setProc.command = ["bash", "-c", "bluetoothctl power " + (on ? "on" : "off") + " >/dev/null 2>&1"]
        _setProc.running = true
    }

    function scan() {
        if (_scanning) return
        _scanning = true
        changed()
        _scanProc.running = true
    }

    function connectDevice(mac) {
        _setProc.command = ["bash", "-c", "bluetoothctl connect " + mac + " >/dev/null 2>&1"]
        _setProc.running = true
    }

    function disconnectDevice(mac) {
        _setProc.command = ["bash", "-c", "bluetoothctl disconnect " + mac + " >/dev/null 2>&1"]
        _setProc.running = true
    }

    function pairDevice(mac) {
        _setProc.command = ["bash", "-c",
            "(echo 'pairable on'; sleep 0.2; echo 'trust " + mac + "'; sleep 0.2; " +
            "echo 'pair " + mac + "'; sleep 3; echo 'connect " + mac + "'; sleep 1; echo 'quit') " +
            "| bluetoothctl >/dev/null 2>&1"]
        _setProc.running = true
    }

    function removeDevice(mac) {
        _setProc.command = ["bash", "-c", "bluetoothctl remove " + mac + " >/dev/null 2>&1"]
        _setProc.running = true
    }

    property Timer _t: Timer {
        interval: 5000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
