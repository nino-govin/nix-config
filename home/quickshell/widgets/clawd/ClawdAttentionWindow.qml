import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/state"
import "../../components/theme"
import "../../services"

PanelWindow {
    id: root

    readonly property var targetScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    readonly property string outputName: targetScreen ? targetScreen.name : ""
    readonly property int pixelScale: SettingsService.clawdScale
    readonly property bool barAtBottom: SettingsService.statusBarPosition !== "top"
        && !SettingsService.statusBarAutoHide
    readonly property bool shown: SettingsService.clawdWidget
        && (ClawdService.state === "attention" || ClawdService.state === "ready")
        && StartupState.maskRevealFinished(outputName)
        && !FloatingWidgetVisibilityService.visibleOnOutput(outputName)
        && !HyprlandService.activeWorkspaceFullscreen(outputName)

    screen: targetScreen
    visible: shown || sprite.current.endsWith("_out")
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "clawd-attention"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        right: true
        bottom: true
    }
    margins.bottom: barAtBottom ? ShellMetrics.statusBarHeight : 0
    implicitWidth: sprite.implicitWidth
    implicitHeight: sprite.implicitHeight

    mask: Region { item: clickArea }

    ClawdSprite {
        id: sprite

        anchors.fill: parent
        pixelScale: root.pixelScale
        animation: !root.shown ? "gone" : ClawdService.state === "ready" ? "nudge" : "peek"
        running: root.visible
    }

    Item {
        id: clickArea

        x: 32 * root.pixelScale
        y: 24 * root.pixelScale
        width: root.width - x
        height: 36 * root.pixelScale

        TapHandler {
            onTapped: ClawdService.activate()
        }
    }
}
