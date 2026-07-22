import QtQuick
import "../theme"

Column {
    id: gauge
    property string label:    "CPU"
    property string value:    "0%"
    property string sub:      "—"
    property real   percent:  0
    property color  barColor: Tokens.color.blue

    spacing: 3

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text:               gauge.label
        font.family:        Tokens.font.sans
        font.pixelSize:     Tokens.font.label
        font.letterSpacing: 0.5
        color:              Tokens.color.fg5
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width:  Tokens.size.gaugeBarW
        height: Tokens.size.gaugeBarH

        Rectangle {
            anchors.fill: parent
            radius: Tokens.radius.sm
            color:  Tokens.color.trackBg
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            width:  parent.width
            height: parent.height * Math.max(0, Math.min(1, gauge.percent / 100))
            radius: Tokens.radius.sm
            color:  gauge.barColor
            Behavior on height { NumberAnimation { duration: 800 } }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text:           gauge.value
        font.family:    Tokens.font.sans
        font.pixelSize: Tokens.font.chip
        font.weight:    Font.DemiBold
        color:          Tokens.color.fg2
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text:           gauge.sub
        font.family:    Tokens.font.sans
        font.pixelSize: Tokens.font.sub
        color:          Tokens.color.fg4
    }
}
