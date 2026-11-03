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
    readonly property real separation: 0.14
    readonly property real readableLuminance: Theme.lightMode ? 0.62 : 0.22
    readonly property color baseTint: Theme.shellBackgroundColor
    readonly property color raisedTint: Theme.mix(baseTint,
        Theme.primaryTextColor, 0.4)
    readonly property real targetLuminance: Theme.lightMode
        ? Math.max(readableLuminance, backgroundLuminance + separation)
        : Math.min(readableLuminance, backgroundLuminance - separation)
    readonly property bool raised: backgroundLuminance >= 0
        && !SettingsService.reduceTransparency
        && (Theme.lightMode
            ? targetLuminance > encodedLuminance(baseTint) - 0.03
            : targetLuminance < encodedLuminance(baseTint) + 0.03)
    readonly property color tintColor: raised ? raisedTint : baseTint
    readonly property real tintOpacity: {
        if (SettingsService.reduceTransparency)
            return 0.85;
        if (backgroundLuminance < 0)
            return 0.55;
        const tint = encodedLuminance(tintColor);
        const needed = raised
            ? separation / Math.abs(tint - backgroundLuminance)
            : (backgroundLuminance - targetLuminance)
                / (backgroundLuminance - tint);
        return Math.max(0.3, Math.min(0.92, needed));
    }

    function encodedLuminance(colorValue: color): real {
        return colorValue.r * 0.2126 + colorValue.g * 0.7152
            + colorValue.b * 0.0722;
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
            color: root.tintColor
            opacity: root.tintOpacity

            Behavior on color {
                MotionColorAnimation { type: MotionAnimation.DefaultEffects }
            }
            Behavior on opacity {
                MotionAnimation { type: MotionAnimation.DefaultEffects }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: ShellMetrics.radiusExtraLarge
        color: "transparent"
        border.width: 1
        border.color: Theme.withOpacity(Theme.primaryTextColor, 0.1)
    }
}
