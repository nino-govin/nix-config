pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME") || ""
    readonly property string statePath:
        (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/clawd/state.json"
    readonly property var states: ["sleeping", "idle", "thinking", "working", "attention"]
    readonly property var tools: ["", "read", "write", "bash", "web", "agent", "think"]

    property string reportedState: "sleeping"
    property string reportedTool: ""
    property int targetPid: 0
    property int sessions: 0
    property real updated: 0
    property real acknowledgedAt: -1
    property string overrideState: ""
    property string overrideTool: ""

    readonly property bool acknowledged: reportedState === "attention"
        && acknowledgedAt === updated
    readonly property string state: overrideState !== "" ? overrideState
        : acknowledged ? (reportedTool !== "" ? "working" : "thinking")
        : reportedState
    readonly property string tool: overrideState !== "" ? overrideTool : reportedTool
    readonly property bool awake: state !== "sleeping"

    signal summonRequested()
    signal performRequested(string animation)
    signal perchRequested(string method)

    function apply(text: string): void {
        let data = null;
        try {
            data = text.trim() ? JSON.parse(text) : null;
        } catch (error) {
            return;
        }
        if (!data || data.sessions === 0 || states.indexOf(data.state) === -1) {
            reportedState = "sleeping";
            reportedTool = "";
            targetPid = 0;
            sessions = 0;
            updated = data && data.updated ? data.updated : 0;
            return;
        }
        reportedState = data.state;
        reportedTool = tools.indexOf(data.tool) !== -1 ? data.tool : "";
        targetPid = data.kittyPid || 0;
        sessions = data.sessions || 0;
        updated = data.updated || 0;
        checkAcknowledged();
    }

    function checkAcknowledged(): void {
        if (reportedState === "attention" && targetPid > 0
                && HyprlandService.activePid === targetPid)
            acknowledgedAt = updated;
    }

    function activate(): void {
        if (sessions === 0)
            Quickshell.execDetached(["kitty", "--directory", homeDirectory, "claude"]);
        else if (targetPid > 0)
            HyprlandService.focusPid(targetPid);
    }

    Connections {
        target: HyprlandService
        function onActivePidChanged(): void { root.checkAcknowledged(); }
    }

    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.apply(text())
        onLoadFailed: root.apply("")
    }

    Process {
        id: refresher
        command: ["clawd-hook", "--refresh"]
        running: true
        onExited: stateFile.reload()
    }

    Timer {
        interval: 15000
        repeat: true
        running: root.sessions > 0
        onTriggered: refresher.running = true
    }

    IpcHandler {
        target: "crab"

        function setState(state: string, tool: string): void {
            if (root.states.indexOf(state) === -1 || root.tools.indexOf(tool) === -1)
                return;
            root.overrideTool = tool;
            root.overrideState = state;
        }

        function clearOverride(): void {
            root.overrideState = "";
            root.overrideTool = "";
        }

        function getState(): string {
            return root.tool !== "" ? root.state + ":" + root.tool : root.state;
        }

        function activate(): void {
            root.activate();
        }

        function summon(): void {
            root.summonRequested();
        }

        function perform(animation: string): void {
            root.performRequested(animation);
        }

        function perch(method: string): void {
            root.perchRequested(method);
        }
    }
}
