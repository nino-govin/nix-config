import QtQuick
import QtQuick.Effects
import "../../components/common"
import "../../components/theme"

Item {
    id: root

    property date now: new Date()
    property int contentAlignment: Text.AlignHCenter
    property real backgroundLuminance: -1
    readonly property color textColor: backgroundLuminance < 0
        ? Theme.primaryTextColor
        : Theme.contrastText(Qt.rgba(backgroundLuminance, backgroundLuminance, backgroundLuminance, 1))
    readonly property color shadowColor: Theme.luminance(textColor) > 0.5 ? "#000000" : "#ffffff"

    Column {
        id: content

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.shadowColor
            shadowOpacity: 0.45
            shadowBlur: 0.8
            shadowVerticalOffset: 1
            shadowHorizontalOffset: 0
        }

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 12
        }
        spacing: -4

        Text {
            width: parent.width
            text: Qt.formatTime(root.now, "hh:mm")
            color: root.textColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 54

            Behavior on color {
                MotionColorAnimation { type: MotionAnimation.DefaultEffects }
            }
            font.weight: Font.Bold
            font.letterSpacing: 12
            horizontalAlignment: root.contentAlignment
        }

        Text {
            width: parent.width
            text: Qt.formatDate(root.now, "dddd, dd MMMM")
            color: root.textColor
            opacity: 0.8
            font.family: Typography.bodyFontFamily
            font.pixelSize: 15
            font.weight: Font.Bold
            horizontalAlignment: root.contentAlignment
        }
    }

    function refreshTime(): void {
        now = new Date();
        const millisecondsIntoMinute = now.getSeconds() * 1000
            + now.getMilliseconds();
        minuteTimer.interval = Math.max(1000, 60000 - millisecondsIntoMinute);
        minuteTimer.restart();
    }

    Timer {
        id: minuteTimer
        repeat: false
        onTriggered: root.refreshTime()
    }

    Component.onCompleted: refreshTime()
}
