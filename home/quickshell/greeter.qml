//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Wayland
import QtQuick
import "components/theme"
import "components/windows"
import "greeter"

ShellRoot {
    GreeterController {
        id: greeterController
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            color: Theme.wallpaperFallbackColor
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "greeter"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            LockScreenContent {
                anchors.fill: parent
                controller: greeterController
                screen: modelData
            }
        }
    }
}
