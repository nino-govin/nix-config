import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property date currentTime
    readonly property string timePattern: SettingsService.clock24Hour
        ? (SettingsService.clockShowSeconds ? "HH:mm:ss" : "HH:mm")
        : (SettingsService.clockShowSeconds ? "hh:mm:ss AP" : "hh:mm AP")

    implicitWidth: content.width
    implicitHeight: 26
    visible: SettingsService.statusBarShowAudio
        || SettingsService.statusBarShowMedia
        || SettingsService.statusBarShowClock

    component BarText: Text {
        height: 26
        color: Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 14
        font.weight: Font.Light
        verticalAlignment: Text.AlignVCenter
    }

    component BarGauge: Item {
        id: gauge

        property real value: 0
        property bool muted: false
        property string icon: ""
        signal clicked()
        signal scrolled(real delta)

        width: 24
        height: 24
        anchors.verticalCenter: parent.verticalCenter

        StatusRing {
            anchors.fill: parent
            value: gauge.value
            ringWidth: 3
            ringColor: gauge.muted ? Theme.mutedTextColor : Theme.accentColor
            onClicked: gauge.clicked()
            onScrolled: delta => gauge.scrolled(delta)
        }

        Text {
            anchors.centerIn: parent
            text: gauge.icon
            color: gauge.muted ? Theme.mutedTextColor : Theme.primaryTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 11
        }
    }

    Row {
        id: content
        height: parent.height
        spacing: 2

        Rectangle {
            visible: SettingsService.statusBarShowAudio
            width: visible ? controls.width + 16 : 0
            height: 26
            radius: height / 2
            color: Theme.panelSurfaceColor

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            MouseArea {
                anchors.fill: parent
                z: -1
                cursorShape: Qt.PointingHandCursor
                onClicked: OverlayState.toggleControlCenter()
            }

            Row {
                id: controls
                height: parent.height
                anchors.centerIn: parent
                spacing: 8

                BarGauge {
                    value: AudioService.volume
                    muted: AudioService.muted
                    icon: AudioService.muted ? Icons.volumeOff : Icons.volume
                    onClicked: OverlayState.toggleControlCenter()
                    onScrolled: delta => AudioService.setVolume(AudioService.volume + delta)
                }

                BarGauge {
                    value: AudioService.microphoneVolume
                    muted: AudioService.microphoneMuted
                    icon: AudioService.microphoneMuted ? Icons.microphoneOff : Icons.microphone
                    onClicked: OverlayState.toggleControlCenter()
                    onScrolled: delta => AudioService.setMicrophoneVolume(
                        AudioService.microphoneVolume + delta)
                }

                BarGauge {
                    value: BrightnessService.brightness
                    muted: BrightnessService.dimmed
                    icon: BrightnessService.dimmed ? Icons.brightnessLow : Icons.brightness
                    onClicked: OverlayState.toggleControlCenter()
                    onScrolled: delta => BrightnessService.setBrightness(
                        BrightnessService.brightness + delta)
                }
            }
        }

        Rectangle {
            visible: SettingsService.statusBarShowMedia
            width: visible ? mediaRow.width + 20 : 0
            height: 26
            radius: height / 2
            color: Theme.panelSurfaceColor

            Row {
                id: mediaRow
                height: parent.height
                anchors.centerIn: parent
                spacing: 7

                Text {
                    height: parent.height
                    text: Icons.media
                    color: Theme.successColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }

                BarText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(180, implicitWidth)
                    text: MediaService.available
                        ? MediaService.artist + " - " + MediaService.title
                        : "No media"
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
            }
        }

        BarText {
            visible: SettingsService.statusBarShowClock
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 8
            text: Qt.formatTime(root.currentTime, root.timePattern) + "  •  "
                + Qt.formatDate(root.currentTime, "dddd, dd MMM yyyy")
            font.pixelSize: 15
        }
    }
}
