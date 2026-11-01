import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    visible: SettingsService.statusBarShowKeyboardLayout
        && KeyboardLayoutService.shortName !== ""
    implicitWidth: content.width
    implicitHeight: 26

    Row {
        id: content

        height: parent.height
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Icons.keyboard
            color: Theme.primaryTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 15
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: KeyboardLayoutService.shortName
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            font.weight: Font.Light
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: KeyboardLayoutService.cycle() }
}
