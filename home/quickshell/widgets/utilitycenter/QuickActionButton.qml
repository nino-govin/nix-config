import QtQuick
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    property bool active: false
    property string icon: ""
    property string label: ""
    signal clicked()

    radius: ShellMetrics.radiusMedium
    color: active ? Theme.accentColor : Theme.selectedSurfaceColor

    Behavior on color {
        MotionColorAnimation { type: MotionAnimation.FastEffects }
    }

    StateLayer {
        anchors.fill: parent
        radius: parent.radius
        hovered: hover.hovered
        pressed: tap.pressed
        stateColor: root.active ? Theme.accentTextColor : Theme.surfaceTextColor
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.active ? Theme.accentTextColor : Theme.accentColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 18
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.active ? Theme.accentTextColor : Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.labelLarge
            font.weight: Font.Medium
        }
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
