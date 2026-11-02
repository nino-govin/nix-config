pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool available: false
    property int percent: 0
    property string status: "Unknown"
    property bool acOnline: false
    property real watts: 0
    property real chargeNow: 0
    property real chargeFull: 0
    property real chargeDesign: 0
    property real flowNow: 0
    property bool energyUnits: false
    property int cycleCount: 0
    readonly property real level: percent / 100
    readonly property bool charging: status === "Charging"
    readonly property bool discharging: status === "Discharging"
    readonly property real healthPercent: chargeDesign > 0
        ? Math.min(100, chargeFull / chargeDesign * 100) : 0
    readonly property string capacityText: chargeFull > 0 && chargeDesign > 0
        ? (chargeFull / 1e6).toFixed(2) + " / " + (chargeDesign / 1e6).toFixed(2)
            + (energyUnits ? " Wh" : " Ah")
        : ""
    readonly property int minutesRemaining: {
        if (flowNow <= 0)
            return -1;
        if (discharging)
            return Math.round(chargeNow / flowNow * 60);
        if (charging && chargeFull > chargeNow)
            return Math.round((chargeFull - chargeNow) / flowNow * 60);
        return -1;
    }

    readonly property string icon: {
        if (charging)
            return "󰚥";
        if (percent > 90) return "󰁹";
        if (percent > 80) return "󰂂";
        if (percent > 70) return "󰂁";
        if (percent > 60) return "󰂀";
        if (percent > 50) return "󰁿";
        if (percent > 40) return "󰁾";
        if (percent > 30) return "󰁽";
        if (percent > 20) return "󰁼";
        if (percent > 10) return "󰁻";
        return "󰁺";
    }

    function formatDuration(minutes: int): string {
        if (minutes < 0)
            return "";
        const hours = Math.floor(minutes / 60);
        const rest = minutes % 60;
        if (hours === 0)
            return rest + " min";
        return hours + " h " + String(rest).padStart(2, "0");
    }

    function parse(line: string): void {
        const fields = line.trim().split("|");
        const number = index => {
            const value = Number(fields[index]);
            return fields[index] !== undefined && fields[index] !== "" && Number.isFinite(value)
                ? value : 0;
        };
        if (fields[1] === undefined || fields[1] === "")
            return;

        available = true;
        acOnline = fields[0] === "1";
        percent = Math.max(0, Math.min(100, number(1)));
        status = fields[2] || "Unknown";
        cycleCount = number(10);

        if (fields[7] !== "") {
            energyUnits = true;
            chargeNow = number(7);
            chargeFull = number(8);
            chargeDesign = number(9);
            const power = Math.abs(number(11));
            flowNow = power;
            watts = power / 1e6;
        } else {
            energyUnits = false;
            chargeNow = number(3);
            chargeFull = number(4);
            chargeDesign = number(5);
            const current = Math.abs(number(6));
            flowNow = current;
            watts = current * number(12) / 1e12;
        }
    }

    Process {
        id: batteryReader
        running: true
        command: ["sh", "-c",
            "ac=0; bat=; for p in /sys/class/power_supply/*; do "
            + "case \"$(cat \"$p/type\" 2>/dev/null)\" in "
            + "Mains) [ \"$(cat \"$p/online\" 2>/dev/null)\" = 1 ] && ac=1;; "
            + "Battery) [ -z \"$bat\" ] && bat=$p;; esac; done; "
            + "[ -n \"$bat\" ] || exit 1; "
            + "r() { cat \"$bat/$1\" 2>/dev/null; }; "
            + "printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\\n' \"$ac\" "
            + "\"$(r capacity)\" \"$(r status)\" \"$(r charge_now)\" \"$(r charge_full)\" "
            + "\"$(r charge_full_design)\" \"$(r current_now)\" \"$(r energy_now)\" "
            + "\"$(r energy_full)\" \"$(r energy_full_design)\" \"$(r cycle_count)\" "
            + "\"$(r power_now)\" \"$(r voltage_now)\""]
        stdout: SplitParser {
            onRead: data => root.parse(data)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!batteryReader.running)
                batteryReader.running = true;
        }
    }
}
