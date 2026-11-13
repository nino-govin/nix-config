import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    required property int port

    implicitWidth: label.implicitWidth + 14
    implicitHeight: 20
    radius: height / 2
    color: Theme.withOpacity(Theme.accentColor, hover.hovered ? 0.28 : 0.14)

    Behavior on color {
        MotionColorAnimation { type: MotionAnimation.FastEffects }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: ":" + root.port
        color: Theme.accentColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: Typography.labelSmall
        font.weight: Font.Medium
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: DevService.openPort(root.port)
    }
}
