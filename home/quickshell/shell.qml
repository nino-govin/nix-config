//@ pragma IconTheme Papirus-Dark
import Quickshell
import QtQuick
import "components/core"
import "components/state"
import "components/windows"
import "integrations"
import "services"
import "widgets/clawd"
import "widgets/statusbar"

ShellRoot {
    Component.onCompleted: {
        ThemeExportService.initialize();
        GreeterSyncService.sync();
        ClawdSoundService.initialize();
    }

    Binding {
        target: NetworkService
        property: "scanningRequested"
        value: OverlayState.utilityCenterVisible
            && OverlayState.utilityPage === "wifi"
    }

    Binding {
        target: BluetoothService
        property: "scanningRequested"
        value: OverlayState.utilityCenterVisible
            && OverlayState.utilityPage === "bluetooth"
    }

    Variants {
        model: Quickshell.screens

        LockTransitionOverlay {}
    }

    LockScreen {}

    Variants {
        model: Quickshell.screens

        WallpaperLayer {}
    }

    Variants {
        model: Quickshell.screens

        WallpaperPickerWindow {}
    }

    SettingsWindow {}

    Variants {
        model: Quickshell.screens

        FloatingWidgetLayer {}
    }

    Variants {
        model: Quickshell.screens

        ScreenOverlay {}
    }

    ClawdAttentionWindow {}

    Variants {
        model: Quickshell.screens

        StatusBar {}
    }
}
