import QtQuick
import "../theme"

Rectangle {
    id: root
    property string iconName: "power"
    property string label:    ""
    property bool   primary:  false

    signal triggered

    implicitWidth:  100
    implicitHeight: 110
    radius: Tokens.radius.xl4
    color:  primary ? Tokens.color.red : Tokens.color.itemBg
    border.color: primary ? "transparent" : Tokens.color.borderFaint
    border.width: 1

    scale: _hover ? 0.95 : 1.0
    Behavior on scale { NumberAnimation { duration: 100 } }
    property bool _hover: false

    Column {
        anchors.centerIn: parent
        spacing: 10

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            icon:  root.iconName
            size:  Tokens.size.iconXl2
            color: root.primary ? Tokens.color.bg0 : Tokens.color.fg3
            strokeWidth: 1.8
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           root.label
            font.family:    Tokens.font.sans
            font.pixelSize: Tokens.font.sm
            font.weight:    root.primary ? Font.DemiBold : Font.Normal
            color:          root.primary ? Tokens.color.bg0 : Tokens.color.fg3
            horizontalAlignment: Text.AlignHCenter
            wrapMode:       Text.WordWrap
            width:          86
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: root._hover = true
        onExited:  root._hover = false
        onClicked: root.triggered()
    }
}
