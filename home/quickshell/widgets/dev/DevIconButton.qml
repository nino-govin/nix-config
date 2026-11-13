import QtQuick
import "../../components/common"
import "../../components/theme"

Item {
    id: root

    property string icon: ""
    property bool danger: false

    signal clicked()

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        anchors.fill: parent
        radius: ShellMetrics.radiusMedium
        color: root.danger && hover.hovered ? Theme.dangerColor : "transparent"

        Behavior on color {
            MotionColorAnimation { type: MotionAnimation.FastEffects }
        }
    }

    StateLayer {
        anchors.fill: parent
        radius: ShellMetrics.radiusMedium
        visible: !root.danger
        hovered: hover.hovered
        pressed: tap.pressed
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.danger && hover.hovered ? Theme.dangerTextColor : Theme.secondaryTextColor
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: 14
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tap
        onTapped: root.clicked()
    }
}
