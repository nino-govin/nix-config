import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    readonly property bool revealed: SettingsService.statusBarShowGpu && GpuPowerService.awake

    visible: width > 0.5
    width: revealed ? content.width + 20 : 0
    height: 26
    radius: height / 2
    color: Theme.statusAccentColor
    opacity: revealed ? 1 : 0
    clip: true

    Behavior on width {
        MotionAnimation { type: MotionAnimation.FastSpatial }
    }

    Behavior on opacity {
        MotionAnimation { type: MotionAnimation.FastEffects }
    }

    Row {
        id: content

        anchors.centerIn: parent
        height: parent.height
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Icons.gpu
            color: Theme.statusAccentTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 15
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: GpuPowerService.inUse
            text: GpuPowerService.clients.length
            color: Theme.statusAccentTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: OverlayState.toggleEnergy() }
}
