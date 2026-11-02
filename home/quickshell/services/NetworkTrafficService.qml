pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property real minimumPeak: 1048576
    readonly property var ignoredInterfaces: /^(lo|docker\d*|veth.*|br-.*|virbr.*|tailscale.*|tun\d*|tap\d*)$/

    property real downloadRate: 0
    property real uploadRate: 0
    property real downloadTotal: 0
    property real uploadTotal: 0
    property real peakRate: minimumPeak
    property real previousDownload: -1
    property real previousUpload: -1
    property real previousTime: 0

    readonly property real downloadProgress: Math.min(1, downloadRate / peakRate)
    readonly property real uploadProgress: Math.min(1, uploadRate / peakRate)

    function rateValue(rate: real): string {
        if (rate >= 10485760)
            return Math.round(rate / 1048576).toString();
        if (rate >= 1048576)
            return (rate / 1048576).toFixed(1);
        if (rate >= 1024)
            return Math.round(rate / 1024).toString();
        return Math.round(rate).toString();
    }

    function rateUnit(rate: real): string {
        return rate >= 1048576 ? "MiB/s" : rate >= 1024 ? "KiB/s" : "B/s";
    }

    function rateText(rate: real): string {
        return rateValue(rate) + " " + rateUnit(rate);
    }

    function formatBytes(bytes: real): string {
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(1) + " GiB";
        return Math.round(bytes / 1048576) + " MiB";
    }

    function applyStats(text: string): void {
        let download = 0;
        let upload = 0;
        for (const line of text.split("\n")) {
            const separator = line.indexOf(":");
            if (separator < 0)
                continue;
            const name = line.slice(0, separator).trim();
            if (root.ignoredInterfaces.test(name))
                continue;
            const fields = line.slice(separator + 1).trim().split(/\s+/).map(Number);
            download += fields[0] || 0;
            upload += fields[8] || 0;
        }

        const now = Date.now();
        const elapsed = (now - previousTime) / 1000;
        if (previousDownload >= 0 && elapsed > 0) {
            downloadRate = Math.max(0, (download - previousDownload) / elapsed);
            uploadRate = Math.max(0, (upload - previousUpload) / elapsed);
            peakRate = Math.max(peakRate, downloadRate, uploadRate);
        }
        previousDownload = download;
        previousUpload = upload;
        previousTime = now;
        downloadTotal = download;
        uploadTotal = upload;
    }

    Process {
        id: statsReader
        running: true
        command: ["cat", "/proc/net/dev"]
        stdout: StdioCollector {
            onStreamFinished: root.applyStats(text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!statsReader.running)
                statsReader.running = true;
        }
    }
}
