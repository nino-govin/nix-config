import Quickshell.Wayland
import QtQuick
import "../theme"

WlSessionLockSurface {
    id: root

    required property var controller

    color: Theme.wallpaperFallbackColor

    LockScreenContent {
        anchors.fill: parent
        controller: root.controller
        screen: root.screen
    }
}
