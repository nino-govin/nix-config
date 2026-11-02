pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool available: false
    property string status: "suspended"
    readonly property bool awake: available && status !== "suspended"
    readonly property var clients: DeviceClientService.nvidiaClients
    readonly property bool inUse: awake && clients.length > 0

    Process {
        id: statusReader
        running: true
        command: ["sh", "-c",
            "for card in /sys/class/drm/card[0-9]*; do "
            + "test \"$(cat \"$card/device/vendor\" 2>/dev/null)\" = 0x10de || continue; "
            + "test \"$(cat \"$card/device/boot_vga\" 2>/dev/null)\" = 0 || continue; "
            + "cat \"$card/device/power/runtime_status\" && exit 0; done; exit 1"]
        stdout: StdioCollector {
            id: statusOutput
        }
        onExited: exitCode => {
            root.available = exitCode === 0;
            if (root.available)
                root.status = statusOutput.text.trim();
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!statusReader.running)
                statusReader.running = true;
        }
    }
}
