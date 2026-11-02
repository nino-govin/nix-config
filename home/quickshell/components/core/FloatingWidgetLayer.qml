import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"
import "../../widgets/clawd"
import "../../widgets/overview"
import "../state"
import "../theme"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData
    readonly property url publishedWallpaper:
        DisplayedWallpaperState.sourceForScreen(targetScreen.name)
    readonly property url displayedWallpaper:
        publishedWallpaper.toString() !== ""
            ? publishedWallpaper : WallpaperService.source
    readonly property real widgetInset: 32 * SettingsService.uiScale
    readonly property bool barOnTop: SettingsService.statusBarPosition === "top"
    readonly property real reservedBarHeight: SettingsService.statusBarAutoHide
        ? 0 : ShellMetrics.statusBarHeight
    readonly property rect usableArea: Qt.rect(
        widgetInset,
        widgetInset + (barOnTop ? reservedBarHeight : 0),
        Math.max(1, width - widgetInset * 2),
        Math.max(1, height - widgetInset * 2 - reservedBarHeight))
    readonly property bool desktopVisible:
        StartupState.maskRevealFinished(targetScreen.name)
        && FloatingWidgetVisibilityService.visibleOnOutput(targetScreen.name)
    readonly property bool floatingWidgetsVisible:
        SettingsService.anyFloatingWidgetEnabled() && desktopVisible
    readonly property bool primaryScreen: Quickshell.screens.length > 0
        && Quickshell.screens[0].name === targetScreen.name

    screen: targetScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "floating-widgets"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    Image {
        id: wallpaperTexture

        anchors.fill: parent
        source: root.displayedWallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
        visible: true
    }

    DesktopOverview {
        id: overview

        anchors.fill: parent
        screenName: root.targetScreen.name
        usableArea: root.usableArea
        wallpaperSource: root.displayedWallpaper
        wallpaperSourceItem: wallpaperTexture
        shown: root.floatingWidgetsVisible
    }

    Clawd {
        anchors.fill: parent
        ceilingY: root.barOnTop ? root.reservedBarHeight : 0
        floorY: root.height - (root.barOnTop ? 0 : root.reservedBarHeight)
        platforms: overview.platforms
        onPoked: (platform, direction) => overview.poke(platform, direction)
        onLanded: platform => overview.poke(platform, "down")
        shown: root.desktopVisible && root.primaryScreen
            && SettingsService.clawdWidget
    }
}
