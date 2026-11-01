import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property bool available: _available
    readonly property bool enabled: _enabled
    readonly property string activeSsid: _activeSsid
    readonly property var networks: _networks
    readonly property bool scanning: _scanning

    signal changed

    property bool   _available: false
    property bool   _enabled:   false
    property string _activeSsid: ""
    property var    _networks:  []
    property bool   _scanning:  false

    property Process _statusProc: Process {
        command: ["bash", "-c",
            "if ! command -v nmcli >/dev/null 2>&1; then echo 'na'; exit; fi; " +
            "en=$(nmcli -t radio wifi 2>/dev/null); " +
            "act=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | " +
            "awk -F: '$2==\"802-11-wireless\"{print $1;exit}'); " +
            "echo \"${en:-disabled}|${act:-}\""
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
                const en = p[0] === "enabled"
                const act = p[1] || ""
                let ch = false
                if (!root._available) { root._available = true; ch = true }
                if (root._enabled !== en)      { root._enabled = en; ch = true }
                if (root._activeSsid !== act)  { root._activeSsid = act; ch = true }
                if (ch) root.changed()
            }
        }
    }

    property Process _scanProc: Process {
        command: ["bash", "-c",
            "nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list 2>/dev/null | " +
            "awk -F: '$1!=\"\"{gsub(/\\\\\\\\/,\"\",$1); print $1\"|\"$2\"|\"$3\"|\"$4}'"
        ]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = new Set()
                const arr = []
                const lines = text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const p = lines[i].split("|")
                    if (p.length < 4 || p[0] === "" || seen.has(p[0])) continue
                    seen.add(p[0])
                    arr.push({
                        ssid:     p[0],
                        signal:   parseInt(p[1]) || 0,
                        security: p[2] || "",
                        inUse:    p[3] === "*"
                    })
                }
                arr.sort((a, b) => b.signal - a.signal)
                root._networks = arr
                root._scanning = false
                root.changed()
            }
        }
    }

    property Process _rescanProc: Process {
        command: ["nmcli", "dev", "wifi", "rescan"]
        running: false
        onExited: {
            _scanProc.running = true
        }
    }

    property Process _actionProc: Process {
        running: false
        onExited: root.refresh()
    }

    function refresh() {
        _statusProc.running = true
        _scanProc.running = true
    }

    function rescan() {
        _scanning = true
        changed()
        _rescanProc.running = true
    }

    function toggle() {
        _actionProc.command = ["nmcli", "radio", "wifi", _enabled ? "off" : "on"]
        _actionProc.running = true
    }

    function connect(ssid, password) {
        if (password && password !== "") {
            _actionProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
        } else {
            _actionProc.command = ["nmcli", "dev", "wifi", "connect", ssid]
        }
        _actionProc.running = true
    }

    function disconnect() {
        if (_activeSsid === "") return
        _actionProc.command = ["nmcli", "connection", "down", _activeSsid]
        _actionProc.running = true
    }

    property Timer _t: Timer {
        interval: 5000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
