pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../components/theme"

Singleton {
    id: root

    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || Quickshell.env("HOME") + "/.config"
    readonly property string colorsPath: configHome + "/quickshell/qt-colors.conf"

    function hex(value: color): string {
        const channel = component => Math.round(component * 255).toString(16).padStart(2, "0");
        return "#ff" + channel(value.r) + channel(value.g) + channel(value.b);
    }

    function roles(disabled: bool): string {
        const text = disabled ? Theme.mutedTextColor : Theme.primaryTextColor;
        return [
            text,
            Theme.surfaceContainerHighColor,
            Theme.mix(Theme.surfaceContainerColor, Theme.primaryTextColor, 0.2),
            Theme.mix(Theme.surfaceContainerColor, Theme.primaryTextColor, 0.1),
            Theme.shellBackgroundColor,
            Theme.surfaceBorderColor,
            text,
            "#ffffff",
            text,
            Theme.shellBackgroundColor,
            Theme.surfaceContainerColor,
            "#000000",
            disabled ? Theme.surfaceBorderColor : Theme.accentColor,
            disabled ? Theme.mutedTextColor : Theme.accentTextColor,
            Theme.accentColor,
            Theme.accentHoverColor,
            Theme.surfaceContainerLowColor,
            Theme.shellBackgroundColor,
            Theme.surfaceContainerColor,
            text,
            Theme.mutedTextColor,
            Theme.accentColor
        ].map(hex).join(", ");
    }

    function exportTheme(): void {
        const active = roles(false);
        colorsFile.setText("[ColorScheme]\n"
            + "active_colors=" + active + "\n"
            + "disabled_colors=" + roles(true) + "\n"
            + "inactive_colors=" + active + "\n");
    }

    FileView {
        id: colorsFile
        path: root.colorsPath
        atomicWrites: true
        printErrors: false
    }
}
