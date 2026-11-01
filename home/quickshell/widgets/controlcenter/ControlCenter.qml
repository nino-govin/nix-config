import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: controlCenter

    property real topPadding: ShellMetrics.panelScreenEdgeOverlap + 28

    GridLayout {
        anchors {
            fill: parent
            topMargin: controlCenter.topPadding
            rightMargin: 18
            bottomMargin: 18
            leftMargin: 18
        }
        columns: 2
        columnSpacing: 14

        Rectangle {
            Layout.preferredWidth: 170
            Layout.fillHeight: true
            radius: ShellMetrics.radiusExtraLarge
            color: Theme.panelSurfaceColor

            RowLayout {
                width: 150
                anchors {
                    top: parent.top
                    topMargin: 6
                    bottom: parent.bottom
                    bottomMargin: 6
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 4

                VerticalAudioFader {
                    icon: AudioService.muted ? Icons.volumeOff : Icons.volume
                    value: AudioService.volume
                    muted: AudioService.muted
                    accentColor: Theme.accentColor
                    onValueMoved: value => AudioService.setVolume(value)
                    onIconClicked: AudioService.toggleMuted()
                }

                VerticalAudioFader {
                    icon: AudioService.microphoneMuted ? Icons.microphoneOff : Icons.microphone
                    value: AudioService.microphoneVolume
                    muted: AudioService.microphoneMuted
                    accentColor: Theme.accentColor
                    onValueMoved: value => AudioService.setMicrophoneVolume(value)
                    onIconClicked: AudioService.toggleMicrophoneMuted()
                }

                VerticalAudioFader {
                    icon: BrightnessService.dimmed ? Icons.brightnessLow : Icons.brightness
                    value: BrightnessService.brightness
                    muted: BrightnessService.dimmed
                    accentColor: Theme.accentColor
                    onValueMoved: value => BrightnessService.setBrightness(value)
                    onIconClicked: BrightnessService.toggleDimmed()
                }
            }
        }

        MediaCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    HoverHandler {
        id: controlCenterHover
    }

    HoverDismissController {
        active: OverlayState.controlCenterVisible
        panelHovered: controlCenterHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hideControlCenter()
    }
}
