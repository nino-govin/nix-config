import QtQuick
import "../theme"

Rectangle {
    id: root
    property string iconName: "wifi"
    property string label:    ""
    property string sublabel: ""
    property bool   active:   false
    property bool   expandable: false

    signal toggled(bool active)
    signal expand

    implicitWidth:  160
    implicitHeight: 58
    radius: Tokens.radius.xl3
    color:  active ? Tokens.color.blue : Tokens.color.itemBg
    border.color: active ? "transparent" : Tokens.color.borderSub
    border.width: 1

    Row {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
        spacing: 10

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            icon:  root.iconName
            size:  Tokens.size.iconXl
            color: root.active ? Tokens.color.bg0 : Tokens.color.fg3
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text:           root.label
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.sm
                font.weight:    Font.DemiBold
                color:          root.active ? Tokens.color.bg0 : Tokens.color.fg2
            }
            Text {
                visible:        root.sublabel !== ""
                text:           root.sublabel
                font.family:    Tokens.font.sans
                font.pixelSize: 9
                color:          root.active ? Qt.rgba(0.18,0.2,0.25,0.7) : Tokens.color.fg4
                width:          root.width - 40 - (root.expandable ? 24 : 8)
                elide:          Text.ElideRight
            }
        }
    }

    Item {
        visible: root.expandable
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom; rightMargin: 4 }
        width: 22

        Rectangle {
            anchors.centerIn: parent
            width: 22; height: 22
            radius: 11
            color: _expandArea.containsMouse
                ? (root.active ? Qt.rgba(0,0,0,0.15) : Tokens.color.bg3)
                : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }
        }

        Icon {
            anchors.centerIn: parent
            icon: "chevronR"
            size: 12
            color: root.active ? Tokens.color.bg0 : Tokens.color.fg3
            strokeWidth: 2.0
        }

        MouseArea {
            id: _expandArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expand()
        }
    }

    MouseArea {
        anchors {
            left: parent.left; top: parent.top; bottom: parent.bottom
            right: parent.right; rightMargin: root.expandable ? 26 : 0
        }
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.active)
    }
}
