pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real brightness: 0
    property real pendingBrightness: 0
    property real restoreBrightness: 0.5
    readonly property bool dimmed: brightness <= 0.01

    function toggleDimmed(): void {
        if (dimmed) {
            setBrightness(restoreBrightness);
        } else {
            restoreBrightness = brightness;
            setBrightness(0.01);
        }
    }

    function setBrightness(value: real): void {
        const clamped = Math.max(0.01, Math.min(1, value));
        brightness = clamped;
        pendingBrightness = clamped;
        writeTimer.restart();
    }

    function readOutput(data: string): void {
        const fields = data.trim().split(",");
        if (fields.length < 4)
            return;

        const percentage = Number(fields[3].replace("%", ""));
        if (!isNaN(percentage))
            brightness = percentage / 100;
    }

    Process {
        id: reader
        running: true
        command: ["brightnessctl", "--machine-readable", "info"]
        stdout: SplitParser { onRead: data => root.readOutput(data) }
    }

    Process {
        id: setter
        onExited: reader.running = true
    }

    Timer {
        id: writeTimer
        interval: 40
        onTriggered: {
            if (setter.running) {
                restart();
                return;
            }

            setter.command = ["brightnessctl", "set",
                Math.round(root.pendingBrightness * 100) + "%"];
            setter.running = true;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!reader.running && !setter.running)
                reader.running = true;
        }
    }
}
