pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real totalKiB: 0
    property real availableKiB: 0
    property real freeKiB: 0
    property real sharedKiB: 0
    property real dirtyKiB: 0
    property real peakKiB: 0
    property real pressureSome: 0
    property real pressureFull: 0
    property var processes: []
    readonly property real usedKiB: Math.max(0, totalKiB - availableKiB)
    readonly property real reclaimableKiB: Math.max(0, availableKiB - freeKiB)
    readonly property real usage: totalKiB > 0 ? usedKiB / totalKiB : 0
    readonly property real reclaimableUsage: totalKiB > 0 ? reclaimableKiB / totalKiB : 0
    readonly property real peakUsage: totalKiB > 0 ? peakKiB / totalKiB : 0
    readonly property string usedFormatted: (usedKiB / 1048576).toFixed(1) + "G"
    readonly property string pressureLevel: pressureFull >= 5 ? "High"
        : pressureSome >= 1 ? "Some" : "None"

    function format(kib: real): string {
        return kib >= 1048576
            ? (kib / 1048576).toFixed(1) + " GiB"
            : Math.round(kib / 1024) + " MiB";
    }

    function refresh(): void {
        if (!memoryInfoReader.running)
            memoryInfoReader.running = true;
    }

    function refreshDetails(): void {
        refresh();
        if (!pressureReader.running)
            pressureReader.running = true;
        if (!processReader.running)
            processReader.running = true;
    }

    function applyMemoryInfo(text: string): void {
        const fields = {};
        for (const line of text.split("\n")) {
            const parts = line.trim().split(/\s+/);
            if (parts.length >= 2)
                fields[parts[0].replace(":", "")] = Number(parts[1]);
        }
        totalKiB = fields.MemTotal || 0;
        availableKiB = fields.MemAvailable || 0;
        freeKiB = fields.MemFree || 0;
        sharedKiB = fields.Shmem || 0;
        dirtyKiB = fields.Dirty || 0;
        peakKiB = Math.max(peakKiB, usedKiB);
    }

    function applyPressure(text: string): void {
        for (const line of text.split("\n")) {
            const match = line.match(/^(some|full) avg10=([\d.]+)/);
            if (!match)
                continue;
            if (match[1] === "some")
                pressureSome = Number(match[2]);
            else
                pressureFull = Number(match[2]);
        }
    }

    function applyProcesses(text: string): void {
        const groups = {};
        for (const line of text.split("\n")) {
            const match = line.trim().match(/^(\d+)\s+(\S+)/);
            if (!match || match[1] === "0")
                continue;
            const name = match[2].split("/").pop().replace(/^\./, "").replace(/-wrapped$/, "");
            const group = groups[name] || (groups[name] = { name: name, rssKiB: 0, count: 0 });
            group.rssKiB += Number(match[1]);
            group.count++;
        }
        processes = Object.values(groups)
            .sort((left, right) => right.rssKiB - left.rssKiB)
            .slice(0, 8);
    }

    Process {
        id: memoryInfoReader
        running: true
        command: ["cat", "/proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: root.applyMemoryInfo(text)
        }
    }

    Process {
        id: pressureReader
        command: ["cat", "/proc/pressure/memory"]
        stdout: StdioCollector {
            onStreamFinished: root.applyPressure(text)
        }
    }

    Process {
        id: processReader
        command: ["ps", "-eo", "rss=,args="]
        stdout: StdioCollector {
            onStreamFinished: root.applyProcesses(text)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
