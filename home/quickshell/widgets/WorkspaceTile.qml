import QtQuick
import Quickshell.Hyprland
import "../theme"

Rectangle {
    id: root
    property int  wsId:   1
    property bool active: false

    implicitWidth:  Tokens.size.tile
    implicitHeight: Tokens.size.tile
    radius: Tokens.radius.md
    color: active ? Tokens.color.blue : _ma.containsMouse ? Tokens.color.bg3 : "#00000000"

    Text {
        anchors.centerIn: parent
        text:           root.wsId
        font.family:    Tokens.font.sans
        font.pixelSize: 10
        font.weight:    active || _ma.containsMouse ? Font.Bold : Font.Normal
        color: active             ? Tokens.color.bg0
             : _ma.containsMouse ? Tokens.color.fg0
             : Tokens.color.fg3
    }

    MouseArea {
        id: _ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    Hyprland.dispatch('hl.dsp.focus({ workspace = ' + root.wsId + ' })')
    }
}
