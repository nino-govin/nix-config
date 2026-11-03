pragma Singleton

import Quickshell
import QtQuick
import "../widgets/clawd/ClawdSounds.js" as Sounds

Singleton {
    id: root

    readonly property string directory:
        Qt.resolvedUrl("../widgets/clawd/assets/sounds/").toString().replace(/^file:\/\//, "")
    readonly property var volumes: ({
        alerts: SettingsService.clawdVolumeAlerts,
        handling: SettingsService.clawdVolumeHandling,
        stunts: SettingsService.clawdVolumeStunts,
        ambient: SettingsService.clawdVolumeAmbient
    })

    property var lastPlayed: ({})
    property string announced: ""
    property bool primed: false

    function initialize(): void {
        primer.start();
    }

    function play(name: string): void {
        const group = Sounds.group(name);
        const volume = SettingsService.clawdVolume / 100 * (volumes[group] || 0) / 100;
        if (!SettingsService.clawdWidget || volume <= 0)
            return;
        const now = Date.now();
        if (now - (lastPlayed[name] || 0) < (Sounds.gaps[name] || 0))
            return;
        lastPlayed[name] = now;
        Quickshell.execDetached(["env", "LC_NUMERIC=C", "pw-play", "--volume", volume.toFixed(3),
            directory + name + ".wav"]);
    }

    function cue(tag: string, frame: int): void {
        const name = Sounds.cue(tag, frame);
        if (name !== "")
            play(name);
    }

    function announce(): void {
        const state = ClawdService.state;
        if (!primed || state === announced) {
            announced = state;
            return;
        }
        if (state === "attention" || state === "ready")
            play(state);
        else if (announced === "sleeping")
            play("wake");
        announced = state;
    }

    Timer {
        id: primer
        interval: 3000
        onTriggered: {
            root.announced = ClawdService.state;
            root.primed = true;
        }
    }

    Connections {
        target: ClawdService
        function onStateChanged(): void { Qt.callLater(root.announce); }
    }
}
