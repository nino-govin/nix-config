pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../../services"

Singleton {
    id: root

    readonly property string controlCenter: "controlCenter"
    readonly property string utilityCenter: "utilityCenter"
    readonly property string launcher: "launcher"
    readonly property string wallpaperPicker: "wallpaperPicker"
    readonly property string powerMenu: "powerMenu"
    readonly property string settings: "settings"

    property string activeOverlay: ""
    property string utilityPage: "notifications"
    property string launcherInitialQuery: ""
    property int launcherRequestSerial: 0
    property string wallpaperOutputName: ""
    property int wallpaperRequestSerial: 0
    property string settingsOutputName: ""
    property int settingsRequestSerial: 0
    property bool statusBarHovered: false
    property string osdKind: "volume"
    property bool osdVisible: false

    readonly property bool controlCenterVisible: activeOverlay === controlCenter
    readonly property bool utilityCenterVisible: activeOverlay === utilityCenter
    readonly property bool launcherVisible: activeOverlay === launcher
    readonly property bool wallpaperPickerVisible: activeOverlay === wallpaperPicker
    readonly property bool powerMenuVisible: activeOverlay === powerMenu
    readonly property bool settingsVisible: activeOverlay === settings

    function toggle(overlay: string): void {
        activeOverlay = activeOverlay === overlay ? "" : overlay;
    }

    function show(overlay: string): void {
        activeOverlay = overlay;
    }

    function hide(overlay: string): void {
        if (activeOverlay === overlay)
            activeOverlay = "";
    }

    function toggleControlCenter(): void {
        toggle(controlCenter);
    }

    function hideControlCenter(): void {
        hide(controlCenter);
    }

    function toggleUtilityCenter(): void {
        toggle(utilityCenter);
    }

    function hideUtilityCenter(): void {
        hide(utilityCenter);
    }

    function toggleLauncher(): void {
        if (launcherVisible) {
            hideLauncher();
        } else {
            showLauncher();
        }
    }

    function showLauncher(): void {
        launcherInitialQuery = "";
        launcherRequestSerial++;
        show(launcher);
    }

    function showClipboardLauncher(): void {
        launcherInitialQuery = "/clip ";
        launcherRequestSerial++;
        show(launcher);
    }

    function showOsd(kind: string): void {
        osdKind = kind;
        osdVisible = true;
        osdTimer.restart();
    }

    function hideLauncher(): void {
        hide(launcher);
    }

    function focusedOutputName(): string {
        const workspace = HyprlandService.workspaces.find(item => item.is_focused);
        return workspace && workspace.output ? workspace.output : "";
    }

    function showWallpaperPicker(): void {
        wallpaperOutputName = focusedOutputName();
        wallpaperRequestSerial++;
        show(wallpaperPicker);
    }

    function hideWallpaperPicker(): void {
        hide(wallpaperPicker);
    }

    function showSettings(): void {
        settingsOutputName = focusedOutputName();
        settingsRequestSerial++;
        show(settings);
    }

    function hideSettings(): void {
        hide(settings);
    }

    function togglePowerMenu(): void {
        toggle(powerMenu);
    }

    function hidePowerMenu(): void {
        hide(powerMenu);
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggleLauncher();
        }

        function show(): void {
            root.showLauncher();
        }

        function showClipboard(): void {
            root.showClipboardLauncher();
        }

        function hide(): void {
            root.hideLauncher();
        }

        function setVisible(visible: bool): void {
            if (visible)
                root.showLauncher();
            else
                root.hideLauncher();
        }

        function getVisible(): bool {
            return root.launcherVisible;
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            if (root.wallpaperPickerVisible)
                root.hideWallpaperPicker();
            else
                root.showWallpaperPicker();
        }

        function show(): void {
            root.showWallpaperPicker();
        }

        function hide(): void {
            root.hideWallpaperPicker();
        }

        function setVisible(visible: bool): void {
            if (visible)
                root.showWallpaperPicker();
            else
                root.hideWallpaperPicker();
        }

        function getVisible(): bool {
            return root.wallpaperPickerVisible;
        }
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.osdVisible = false
    }

    IpcHandler {
        target: "audio"

        function raise(): void {
            if (AudioService.muted)
                AudioService.toggleMuted();
            AudioService.setVolume(AudioService.volume + 0.05);
            root.showOsd("volume");
        }

        function lower(): void {
            AudioService.setVolume(AudioService.volume - 0.05);
            root.showOsd("volume");
        }

        function toggleMute(): void {
            AudioService.toggleMuted();
            root.showOsd("volume");
        }

        function toggleMicMute(): void {
            AudioService.toggleMicrophoneMuted();
            root.showOsd("microphone");
        }
    }

    IpcHandler {
        target: "brightness"

        function raise(): void {
            BrightnessService.setBrightness(BrightnessService.brightness + 0.05);
            root.showOsd("brightness");
        }

        function lower(): void {
            BrightnessService.setBrightness(BrightnessService.brightness - 0.05);
            root.showOsd("brightness");
        }
    }

    IpcHandler {
        target: "notifications"

        function toggleDoNotDisturb(): void {
            NotificationService.toggleDoNotDisturb();
        }
    }

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            root.togglePowerMenu();
        }

        function hide(): void {
            root.hidePowerMenu();
        }
    }

    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            root.toggleControlCenter();
        }
    }

    IpcHandler {
        target: "utilitycenter"

        function toggle(): void {
            root.toggleUtilityCenter();
        }
    }

    IpcHandler {
        target: "settings"

        function toggle(): void {
            if (root.settingsVisible)
                root.hideSettings();
            else
                root.showSettings();
        }
    }
}
