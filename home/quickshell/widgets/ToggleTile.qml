import QtQuick
import "../theme"

Rectangle {
    id: root
    property string iconName: "wifi"
    property string label:    ""
    property string sublabel: ""
    property bool   active:   false

    signal toggled(bool active)

    implicitWidth:  160
    implicitHeight: 58
    radius: Tokens.radius.xl3
    color:  active ? Tokens.color.blue : Tokens.color.itemBg
    border.color: active ? "transparent" : Tokens.color.borderSub
    border.width: 1

    layer.enabled: active
    layer.effect: null

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
            }
        }
    }

    TapHandler { onTapped: root.toggled(!root.active) }
}
