pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../components/theme"
import "../services"

Singleton {
    id: root

    readonly property string targetDirectory: "/var/lib/jaqc-greeter"

    function sync(): void {
        syncTimer.restart();
    }

    Component.onCompleted: sync()

    Connections {
        target: WallpaperService
        function onSourceChanged(): void { root.sync(); }
    }

    Connections {
        target: Theme
        function onAccentColorChanged(): void { root.sync(); }
        function onShellBackgroundColorChanged(): void { root.sync(); }
    }

    Connections {
        target: SettingsService
        function onProfilePictureSourceChanged(): void { root.sync(); }
        function onEffectiveDisplayNameChanged(): void { root.sync(); }
        function onClock24HourChanged(): void { root.sync(); }
    }

    Timer {
        id: syncTimer
        interval: 1500
        onTriggered: {
            const settings = SettingsService.snapshot();
            settings.profilePicture = "";
            syncer.command = ["sh", "-c",
                "set -e\n"
                + "d=\"$1\"; test -w \"$d\" || exit 0\n"
                + "decode() { printf '%b' \"$(printf '%s' \"${1#file://}\" | sed 's/%/\\\\x/g')\"; }\n"
                + "mkdir -p \"$d/quickshell\"\n"
                + "printf '%s\\n' \"$2\" > \"$d/quickshell/settings.json\"\n"
                + "wallpaper=$(decode \"$3\")\n"
                + "rm -f \"$d\"/wallpaper.*\n"
                + "target=\"$d/wallpaper.${wallpaper##*.}\"\n"
                + "cp \"$wallpaper\" \"$target\"\n"
                + "printf 'file://%s' \"$target\" > \"$d/quickshell/wallpaper-selection\"\n"
                + "picture=$(decode \"$4\")\n"
                + "if test -f \"$picture\"; then cp \"$picture\" \"$d/.face\"; else rm -f \"$d/.face\"; fi\n"
                + "chmod -R a+rX \"$d\"",
                "sh", root.targetDirectory, JSON.stringify(settings, null, 2),
                WallpaperService.source.toString(), SettingsService.profilePictureSource];
            syncer.running = true;
        }
    }

    Process {
        id: syncer
        stderr: StdioCollector {
            onStreamFinished: if (text.trim() !== "") console.warn("GreeterSyncService:", text.trim())
        }
    }
}
