import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    readonly property string kind: OverlayState.osdKind
    readonly property real value: kind === "brightness" ? BrightnessService.brightness
        : kind === "microphone" ? AudioService.microphoneVolume
        : AudioService.volume
    readonly property bool muted: kind === "brightness" ? BrightnessService.dimmed
        : kind === "microphone" ? AudioService.microphoneMuted
        : AudioService.muted
    readonly property string icon: kind === "brightness"
        ? (muted ? Icons.brightnessLow : Icons.brightness)
        : kind === "microphone"
            ? (muted ? Icons.microphoneOff : Icons.microphone)
            : (muted ? Icons.volumeOff : Icons.volume)
    property real displayedValue: value

    Behavior on displayedValue {
        SmoothedAnimation { velocity: ShellMetrics.continuousMotionVelocity }
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: 20
            right: parent.right
            rightMargin: 20
            top: parent.top
            topMargin: 18
        }
        height: 36
        spacing: 14

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            text: root.icon
            color: root.muted ? Theme.mutedTextColor : Theme.primaryTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: track

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 24 - percentage.width - parent.spacing * 2
            height: 8
            radius: height / 2
            color: Theme.surfaceBorderColor

            Rectangle {
                width: Math.max(height, track.width * Math.min(1, root.displayedValue))
                height: parent.height
                radius: parent.radius
                color: root.muted ? Theme.mutedTextColor : Theme.accentColor

                Behavior on color {
                    MotionColorAnimation { type: MotionAnimation.FastEffects }
                }
            }
        }

        Text {
            id: percentage

            anchors.verticalCenter: parent.verticalCenter
            width: 40
            text: Math.round(root.value * 100) + "%"
            color: root.muted ? Theme.mutedTextColor : Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignRight
        }
    }
}
