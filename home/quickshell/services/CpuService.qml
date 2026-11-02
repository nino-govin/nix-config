pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real usage: 0
    readonly property int percent: Math.round(usage * 100)
    property real temperature: 0
    property bool temperatureAvailable: false
    property real gpuTemperature: 0
    property bool gpuAvailable: false
    property string gpuName: "Dedicated GPU"
    property real gpuUsage: 0
    readonly property int gpuPercent: Math.round(gpuUsage * 100)
    property bool gpuUsageAvailable: false
    property real gpuMemoryUsed: 0
    property real gpuMemoryTotal: 0
    property real previousIdle: 0
    property real previousTotal: 0

    function update(values: var): void {
        const idle = values[3] + values[4];
        const total = values.reduce((sum, value) => sum + value, 0);
        const totalDelta = total - root.previousTotal;
        const idleDelta = idle - root.previousIdle;

        if (root.previousTotal > 0 && totalDelta > 0)
            root.usage = Math.max(0, Math.min(1, 1 - idleDelta / totalDelta));

        root.previousIdle = idle;
        root.previousTotal = total;
    }

    Process {
        id: cpuStatReader
        running: true
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("cpu "))
                    root.update(data.trim().split(/\s+/).slice(1).map(Number));
            }
        }
    }

    Process {
        id: temperatureReader
        command: ["sh", "-c",
            "for d in /sys/class/hwmon/hwmon*; do "
            + "name=$(cat \"$d/name\" 2>/dev/null) || continue; "
            + "case \"$name\" in k10temp|coretemp|zenpower) "
            + "cat \"$d/temp1_input\" 2>/dev/null && exit 0;; esac; done; "
            + "for z in /sys/class/thermal/thermal_zone*; do "
            + "type=$(cat \"$z/type\" 2>/dev/null) || continue; "
            + "case \"$type\" in x86_pkg_temp|cpu-thermal|acpitz) "
            + "cat \"$z/temp\" 2>/dev/null && exit 0;; esac; done; exit 1"]
        stdout: StdioCollector {
            id: temperatureOutput
        }
        onExited: (exitCode, exitStatus) => {
            const value = Number(temperatureOutput.text.trim()) / 1000;
            root.temperatureAvailable = exitCode === 0 && Number.isFinite(value);
            if (root.temperatureAvailable)
                root.temperature = value;
        }
    }

    Process {
        id: gpuReader
        command: ["sh", "-c",
            "for card in /sys/class/drm/card[0-9]*; do "
            + "test -r \"$card/device/boot_vga\" || continue; "
            + "test \"$(cat \"$card/device/boot_vga\")\" = 0 || continue; "
            + "vendor=$(cat \"$card/device/vendor\" 2>/dev/null); "
            + "if test \"$vendor\" = 0x10de && command -v nvidia-smi >/dev/null; then "
            + "test \"$(cat \"$card/device/power/runtime_status\")\" = active || exit 1; "
            + "find /proc/[0-9]*/fd -lname '/dev/nvidia[0-9]*' -print -quit "
            + "2>/dev/null | grep -q . || exit 1; "
            + "nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,"
            + "memory.used,memory.total --format=csv,noheader,nounits "
            + "| head -n1 | sed 's/, /|/g'; exit 0; fi; "
            + "for h in \"$card/device/hwmon\"/hwmon*; do "
            + "test -r \"$h/temp1_input\" || continue; "
            + "case \"$vendor\" in 0x1002) name='AMD GPU';; "
            + "0x8086) name='Intel GPU';; *) name='Dedicated GPU';; esac; "
            + "temp=$(cat \"$h/temp1_input\"); "
            + "busy=$(cat \"$card/device/gpu_busy_percent\" 2>/dev/null); "
            + "used=$(cat \"$card/device/mem_info_vram_used\" 2>/dev/null); "
            + "total=$(cat \"$card/device/mem_info_vram_total\" 2>/dev/null); "
            + "printf '%s|%s|%s|%s|%s\\n' \"$name\" \"$((temp / 1000))\" \"$busy\" "
            + "\"${used:+$((used / 1048576))}\" \"${total:+$((total / 1048576))}\"; "
            + "exit 0; done; done; exit 1"]
        stdout: StdioCollector {
            id: gpuOutput
        }
        onExited: (exitCode, exitStatus) => {
            const fields = gpuOutput.text.trim().split("|");
            const number = text => text !== undefined && text.trim() !== ""
                ? Number(text) : NaN;
            const temperature = number(fields[1]);
            const usage = number(fields[2]);
            root.gpuAvailable = exitCode === 0 && fields.length === 5
                && Number.isFinite(temperature);
            if (!root.gpuAvailable)
                return;
            root.gpuName = fields[0];
            root.gpuTemperature = temperature;
            root.gpuUsageAvailable = Number.isFinite(usage);
            root.gpuUsage = root.gpuUsageAvailable
                ? Math.max(0, Math.min(1, usage / 100)) : 0;
            root.gpuMemoryUsed = number(fields[3]) || 0;
            root.gpuMemoryTotal = number(fields[4]) || 0;
        }
    }

    Timer {
        id: refreshTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!cpuStatReader.running)
                cpuStatReader.running = true;
            if (!temperatureReader.running)
                temperatureReader.running = true;
            if (!gpuReader.running)
                gpuReader.running = true;
        }
    }

    Component.onCompleted: {
        temperatureReader.running = true;
        gpuReader.running = true;
    }
}
