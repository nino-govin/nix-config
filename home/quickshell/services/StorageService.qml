pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real totalBytes: 0
    property real usedBytes: 0
    readonly property bool available: totalBytes > 0
    readonly property real usage: available ? usedBytes / totalBytes : 0
    readonly property int percent: Math.round(usage * 100)

    function format(bytes: real): string {
        return bytes >= 1099511627776
            ? (bytes / 1099511627776).toFixed(2) + " TiB"
            : (bytes / 1073741824).toFixed(0) + " GiB";
    }

    function applyUsage(text: string): void {
        const fields = text.trim().split("\n").pop().trim().split(/\s+/).map(Number);
        if (fields.length < 2 || !fields.every(Number.isFinite))
            return;
        totalBytes = fields[0];
        usedBytes = fields[1];
    }

    Process {
        id: usageReader
        running: true
        command: ["df", "-B1", "--output=size,used", "/"]
        stdout: StdioCollector {
            onStreamFinished: root.applyUsage(text)
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            if (!usageReader.running)
                usageReader.running = true;
        }
    }
}
