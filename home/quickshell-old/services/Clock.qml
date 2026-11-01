import QtQuick
import Quickshell.Io

QtObject {
    id: root
    readonly property string time:      Qt.formatTime(now, "HH:mm")
    readonly property string date:      Qt.formatDate(now, "dddd d MMMM yyyy")
    readonly property string dateShort: Qt.formatDate(now, "yyyy-MM-dd")
    readonly property string timezone:  _tz
    readonly property string uptime:    _uptime
    readonly property int    isoWeek:   _isoWeek(now)
    readonly property string dayOfWeek: Qt.formatDate(now, "dddd")

    property var    now: new Date()
    property string _tz: "—"
    property string _uptime: "—"

    property Process _tzProc: Process {
        command: ["bash", "-c", "timedatectl show --value -p Timezone 2>/dev/null || readlink /etc/localtime | sed 's|.*zoneinfo/||' || echo '—'"]
        running: true
        stdout: SplitParser { onRead: data => { _tz = data.trim() || "—" } }
    }

    function _isoWeek(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
        const day = t.getUTCDay() || 7
        t.setUTCDate(t.getUTCDate() + 4 - day)
        const yearStart = new Date(Date.UTC(t.getUTCFullYear(), 0, 1))
        return Math.ceil((((t - yearStart) / 86400000) + 1) / 7)
    }

    property Process _upProc: Process {
        command: ["bash", "-c",
            "s=$(awk '{print int($1)}' /proc/uptime); " +
            "d=$((s/86400)); h=$(((s%86400)/3600)); m=$(((s%3600)/60)); " +
            "if [ $d -gt 0 ]; then printf \"%dd %dh %dm\" $d $h $m; " +
            "elif [ $h -gt 0 ]; then printf \"%dh %dm\" $h $m; " +
            "else printf \"%dm\" $m; fi"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => { _uptime = data.trim() }
        }
    }

    property Timer _t: Timer {
        interval: 1000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: now = new Date()
    }

    property Timer _upT: Timer {
        interval: 60000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: _upProc.running = true
    }
}
