pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var cameraClients: []
    property var nvidiaClients: []

    function apply(text: string): void {
        const camera = [];
        const nvidia = [];
        for (const line of text.split("\n")) {
            const fields = line.split("|");
            if (fields.length < 3)
                continue;
            const name = fields[1].replace(/^\./, "").replace(/-wrapp?e?d?$/, "");
            const client = { pid: Number(fields[0]), name: name || fields[0] };
            const list = fields[2].startsWith("/dev/video") ? camera : nvidia;
            if (!list.some(item => item.pid === client.pid))
                list.push(client);
        }
        if (JSON.stringify(camera) !== JSON.stringify(cameraClients))
            cameraClients = camera;
        if (JSON.stringify(nvidia) !== JSON.stringify(nvidiaClients))
            nvidiaClients = nvidia;
    }

    Process {
        id: scanner
        running: true
        command: ["sh", "-c",
            "find /proc/[0-9]*/fd \\( -lname '/dev/video*' -o -lname '/dev/nvidia[0-9]*' \\) "
            + "-printf '%h %l\\n' 2>/dev/null | sort -u | while read -r dir link; do "
            + "pid=${dir#/proc/}; pid=${pid%/fd}; "
            + "printf '%s|%s|%s\\n' \"$pid\" \"$(cat \"/proc/$pid/comm\" 2>/dev/null)\" \"$link\"; "
            + "done"]
        stdout: StdioCollector {
            onStreamFinished: root.apply(text)
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!scanner.running)
                scanner.running = true;
        }
    }
}
