pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    property bool screencopyActive: false

    readonly property var activeGroups: Pipewire.linkGroups.values.filter(group =>
        group.source && group.target && group.target.isStream
        && !group.source.isStream && group.state === PwLinkState.Active)

    readonly property var microphoneGroups: activeGroups.filter(group =>
        (group.source.type & PwNodeType.AudioSource) === PwNodeType.AudioSource)
    readonly property var videoGroups: activeGroups.filter(group =>
        (group.source.type & PwNodeType.VideoSource) === PwNodeType.VideoSource)
    readonly property var cameraGroups: videoGroups.filter(group => isCamera(group.source))
    readonly property var screencastGroups: videoGroups.filter(group => !isCamera(group.source))

    readonly property var microphoneApps: appNames(microphoneGroups)
    readonly property var cameraApps: unique(appNames(cameraGroups)
        .concat(DeviceClientService.cameraClients.map(client => client.name)))
    readonly property var screencastApps: appNames(screencastGroups)

    readonly property bool microphoneActive: microphoneApps.length > 0
    readonly property bool cameraActive: cameraApps.length > 0
    readonly property bool screencastActive: screencastApps.length > 0
        || screencopyActive
    readonly property bool anyActive: microphoneActive || cameraActive || screencastActive

    function isCamera(node: var): bool {
        return node.name.startsWith("v4l2_") || node.name.startsWith("libcamera");
    }

    function cleanName(name: string): string {
        return name.replace(/^\./, "").replace(/-wrapp?e?d?$/, "");
    }

    function unique(names: var): var {
        return names.filter((name, index) => name && names.indexOf(name) === index);
    }

    function appNames(groups: var): var {
        return unique(groups.map(group => {
            const node = group.target;
            const properties = node.properties || {};
            return cleanName(properties["application.name"] || node.name || node.description);
        }));
    }

    function trackScreencopy(data: string): void {
        if (data.startsWith("1")) {
            screencopyRelease.stop();
            screencopyActive = true;
        } else {
            screencopyRelease.restart();
        }
    }

    Timer {
        id: screencopyRelease
        interval: 1500
        onTriggered: root.screencopyActive = false
    }

    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "screencastv2")
                root.trackScreencopy(event.data);
        }
    }

    PwObjectTracker {
        objects: Pipewire.linkGroups.values
    }

    PwObjectTracker {
        objects: root.activeGroups.map(group => group.target)
    }
}
