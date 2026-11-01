import QtQuick
import "../../components/theme"
import "../../services"

QtObject {
    readonly property var allItems: [
        {
            key: "command:settings",
            type: "command",
            name: "Settings",
            detail: "Open shell settings",
            command: "settings",
            icon: Icons.settings,
            enabled: SettingsService.launcherCommandSettings
        },
        {
            key: "command:color-scheme",
            type: "command",
            name: "Color scheme",
            detail: "Switch shell palette",
            command: "colorScheme",
            icon: Icons.colorScheme,
            enabled: SettingsService.launcherCommandColors
        },
        {
            key: "command:clipboard",
            type: "command",
            name: "Clipboard",
            detail: "Paste from clipboard history",
            command: "clipboard",
            icon: Icons.clipboard,
            enabled: SettingsService.launcherCommandClipboard
        },
        {
            key: "command:wallpapers",
            type: "command",
            name: "Wallpapers",
            detail: "Choose a wallpaper",
            command: "wallpapers",
            icon: Icons.wallpaper,
            enabled: SettingsService.launcherCommandWallpapers
        }
    ]

    readonly property var items: allItems.filter(item => item.enabled)
}
