pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME")

    property bool dockerAvailable: false
    property var containers: []
    property var servers: []
    property var stats: ({})
    property var expandedProjects: ({})
    property bool detailed: false

    readonly property var runningContainers: containers.filter(container => container.running)
    readonly property int activeCount: runningContainers.length + servers.length
    readonly property var projects: {
        const groups = {};
        for (const container of containers) {
            const key = container.project || "";
            if (!groups[key])
                groups[key] = { name: key, containers: [] };
            groups[key].containers.push(container);
        }
        return Object.values(groups).map(group => {
            const running = group.containers.filter(container => container.running);
            const usage = running.map(container => root.stats[container.id]).filter(stat => stat !== undefined);
            return {
                name: group.name,
                containers: group.containers.sort((first, second) => (second.running - first.running) || first.label.localeCompare(second.label)),
                running: running.length,
                cpu: usage.reduce((sum, stat) => sum + stat.cpu, 0),
                memory: usage.reduce((sum, stat) => sum + stat.memory, 0),
                hasStats: usage.length > 0
            };
        }).sort((first, second) => (second.running > 0) - (first.running > 0) || first.name.localeCompare(second.name));
    }
    readonly property real totalCpu: projects.reduce((sum, project) => sum + project.cpu, 0)
    readonly property real totalMemory: projects.reduce((sum, project) => sum + project.memory, 0)

    function isExpanded(project: var): bool {
        const value = expandedProjects[project.name];
        return value === undefined ? project.running > 0 : value;
    }

    function toggleProject(project: var): void {
        const next = Object.assign({}, expandedProjects);
        next[project.name] = !isExpanded(project);
        expandedProjects = next;
    }

    function containerAction(action: string, ids: var): void {
        if (ids.length > 0)
            Quickshell.execDetached(["docker", action, ...ids]);
    }

    function containerLogs(container: var): void {
        Quickshell.execDetached(["kitty", "--title", container.name + " logs", "docker", "logs", "-f", "--tail", "200", container.name]);
    }

    function projectLogs(project: var): void {
        Quickshell.execDetached(["kitty", "--title", project.name + " logs", "docker", "compose", "-p", project.name, "logs", "-f", "--tail", "100"]);
    }

    function openPort(port: int): void {
        Quickshell.execDetached(["xdg-open", "http://localhost:" + port]);
    }

    function stopServer(server: var): void {
        Quickshell.execDetached(["kill", String(server.pid)]);
        servers = servers.filter(entry => entry.pid !== server.pid);
    }

    function shortPath(path: string): string {
        return path.startsWith(homeDirectory) ? "~" + path.slice(homeDirectory.length) : path;
    }

    function formatMemory(bytes: real): string {
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(1) + " GiB";
        return Math.round(bytes / 1048576) + " MiB";
    }

    function parseBytes(text: string): real {
        const match = text.trim().match(/^([\d.]+)\s*([KMGT]?i?B)$/);
        if (!match)
            return 0;
        const units = { B: 1, KiB: 1024, MiB: 1048576, GiB: 1073741824, TiB: 1099511627776, kB: 1000, KB: 1000, MB: 1e6, GB: 1e9, TB: 1e12 };
        return parseFloat(match[1]) * (units[match[2]] || 1);
    }

    function refresh(): void {
        if (!containerReader.running)
            containerReader.running = true;
        if (!serverReader.running)
            serverReader.running = true;
    }

    function parseContainer(line: string): var {
        const data = JSON.parse(line);
        const labels = {};
        for (const pair of (data.Labels || "").split(",")) {
            const separator = pair.indexOf("=");
            if (separator > 0)
                labels[pair.slice(0, separator)] = pair.slice(separator + 1);
        }
        const ports = [];
        const portPattern = /:(\d+)->/g;
        let match;
        while ((match = portPattern.exec(data.Ports || "")) !== null) {
            const port = parseInt(match[1]);
            if (!ports.includes(port))
                ports.push(port);
        }
        const health = data.Status.match(/\((healthy|unhealthy|health: starting)\)/);
        return {
            id: data.ID,
            name: data.Names,
            label: labels["com.docker.compose.service"] || data.Names,
            project: labels["com.docker.compose.project"] || "",
            running: data.State === "running",
            state: data.State,
            health: health ? health[1].replace("health: ", "") : "",
            status: data.Status.replace(/\s*\(.*\)$/, ""),
            ports: ports
        };
    }

    Process {
        id: containerReader
        command: ["docker", "ps", "-a", "--format", "{{json .}}"]
        stdout: StdioCollector {
            id: containerOutput
        }
        onExited: code => {
            root.dockerAvailable = code === 0;
            if (code !== 0) {
                root.containers = [];
                return;
            }
            root.containers = containerOutput.text.split("\n").filter(line => line.length > 0)
                .map(line => root.parseContainer(line))
                .filter(container => container.running || container.project !== "");
        }
    }

    Process {
        id: statsReader
        command: ["docker", "stats", "--no-stream", "--format", "{{.ID}}\t{{.CPUPerc}}\t{{.MemUsage}}"]
        stdout: StdioCollector {
            id: statsOutput
        }
        onExited: code => {
            if (code !== 0)
                return;
            const next = {};
            for (const line of statsOutput.text.split("\n")) {
                const fields = line.split("\t");
                if (fields.length === 3)
                    next[fields[0]] = {
                        cpu: parseFloat(fields[1]) || 0,
                        memory: root.parseBytes(fields[2].split("/")[0])
                    };
            }
            root.stats = next;
        }
    }

    Process {
        id: serverReader
        command: ["sh", "-c",
            "ss -ltnpH | awk '{n=split($4,a,\":\"); if (match($0,/pid=[0-9]+/)) print a[n], substr($0,RSTART+4,RLENGTH-4)}' "
            + "| sort -u -k1,1n | while read port pid; do cwd=$(readlink /proc/$pid/cwd) || continue; "
            + "case \"$cwd\" in \"$HOME\"/?*) printf '%s\\t%s\\t%s\\t%s\\n' \"$port\" \"$pid\" \"$(cat /proc/$pid/comm)\" \"$cwd\";; esac; done"]
        stdout: StdioCollector {
            id: serverOutput
        }
        onExited: {
            root.servers = serverOutput.text.split("\n").filter(line => line.length > 0).map(line => {
                const fields = line.split("\t");
                return {
                    port: parseInt(fields[0]),
                    pid: parseInt(fields[1]),
                    command: fields[2],
                    directory: fields[3],
                    name: fields[3].split("/").pop()
                };
            });
        }
    }

    Process {
        id: events
        running: true
        command: ["docker", "events", "--filter", "type=container", "--filter", "event=create", "--filter", "event=start", "--filter", "event=stop", "--filter", "event=die", "--filter", "event=destroy", "--filter", "event=pause", "--filter", "event=unpause", "--filter", "event=health_status", "--format", "{{.Action}}"]
        stdout: SplitParser {
            onRead: eventDebounce.restart()
        }
        onExited: eventRetry.restart()
    }

    Timer {
        id: eventDebounce
        interval: 300
        onTriggered: root.refresh()
    }

    Timer {
        id: eventRetry
        interval: 10000
        onTriggered: events.running = true
    }

    Timer {
        interval: root.detailed ? 3000 : 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refresh();
            if (root.detailed && root.dockerAvailable && root.runningContainers.length > 0 && !statsReader.running)
                statsReader.running = true;
        }
    }

    onDetailedChanged: {
        if (detailed)
            refresh();
    }
}
