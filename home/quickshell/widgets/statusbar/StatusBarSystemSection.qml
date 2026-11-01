import QtQuick
import Quickshell.Services.SystemTray
import "../../components/state"
import "../../components/theme"
import "../../services"
import "../systemtray"

Item {
    id: root

    implicitWidth: content.width
    implicitHeight: 26

    Row {
        id: content
        height: parent.height
        spacing: 10

        KeyboardLayoutIndicator {
            anchors.verticalCenter: parent.verticalCenter
        }
        BatteryIndicator {
            visible: SettingsService.statusBarShowBattery
            anchors.verticalCenter: parent.verticalCenter
        }
        MemoryIndicator {
            visible: SettingsService.statusBarShowMemory
            anchors.verticalCenter: parent.verticalCenter
        }

        SystemTrayIndicator {
            visible: SettingsService.statusBarShowSystemTray && SystemTray.items.values.length > 0
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            visible: SettingsService.statusBarShowTray
            width: visible ? trayIcons.width + 20 : 0
            height: 26
            radius: height / 2
            color: Theme.statusAccentColor

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: OverlayState.toggleUtilityCenter() }

            Row {
                id: trayIcons
                height: parent.height
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: [SettingsService.doNotDisturb ? Icons.notificationsOff : Icons.notifications, Icons.wifi, Icons.bluetooth]
                    Text {
                        required property string modelData
                        height: 26
                        text: modelData
                        color: Theme.statusAccentTextColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 15
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
