import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property Item wallpaperSourceItem
    required property rect wallpaperRect
    readonly property real blurMargin: 48
    readonly property real cropX: Math.max(0,
        wallpaperRect.x - blurMargin)
    readonly property real cropY: Math.max(0,
        wallpaperRect.y - blurMargin)
    readonly property real cropRight: Math.min(wallpaperSourceItem.width,
        wallpaperRect.x + wallpaperRect.width + blurMargin)
    readonly property real cropBottom: Math.min(wallpaperSourceItem.height,
        wallpaperRect.y + wallpaperRect.height + blurMargin)
    readonly property real backgroundLuminance: wallpaperSourceItem.width > 0
        && wallpaperSourceItem.height > 0
        ? FloatingWidgetPlacementService.regionLuminance(
            WallpaperService.source.toString(), Qt.rect(
                wallpaperRect.x / wallpaperSourceItem.width,
                wallpaperRect.y / wallpaperSourceItem.height,
                wallpaperRect.width / wallpaperSourceItem.width,
                wallpaperRect.height / wallpaperSourceItem.height))
        : -1
    readonly property real tintOpacity: {
        if (SettingsService.reduceTransparency)
            return 0.85;
        if (backgroundLuminance < 0)
            return 0.55;
        const target = Theme.lightMode ? 0.62 : 0.22;
        const tint = Theme.lightMode ? 0.92 : 0.04;
        const needed = (backgroundLuminance - target) / (backgroundLuminance - tint);
        return Math.max(0.35, Math.min(0.85, needed));
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: ShellMetrics.radiusExtraLarge
        color: "transparent"
        contentUnderBorder: true

        ShaderEffectSource {
            id: wallpaperCrop

            x: root.cropX - root.wallpaperRect.x
            y: root.cropY - root.wallpaperRect.y
            width: Math.max(1, root.cropRight - root.cropX)
            height: Math.max(1, root.cropBottom - root.cropY)
            sourceItem: root.wallpaperSourceItem
            hideSource: true
            sourceRect: Qt.rect(root.cropX, root.cropY, width, height)
            textureSize: Qt.size(width, height)
            live: true
            smooth: true
        }

        MultiEffect {
            anchors.fill: wallpaperCrop
            source: wallpaperCrop
            autoPaddingEnabled: false
            blurEnabled: !SettingsService.reduceTransparency
                && SettingsService.blurStrength > 0
            blur: SettingsService.blurStrength
            blurMax: 64
            blurMultiplier: 1.5 * Math.max(0.25, SettingsService.blurStrength)
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.shellBackgroundColor
            opacity: root.tintOpacity

            Behavior on opacity {
                MotionAnimation { type: MotionAnimation.DefaultEffects }
            }
        }
    }
}
