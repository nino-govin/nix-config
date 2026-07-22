import QtQuick
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    property int wsId:   1
    property bool active: false
    property var  hyprland: null

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
        color: active              ? Tokens.color.bg0
             : _ma.containsMouse  ? Tokens.color.fg0
             : Tokens.color.fg3
    }

    MouseArea {
        id: _ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    _proc.running = true
    }

    Process {
        id: _proc
        command: ["hyprctl", "dispatch", "workspace", root.wsId.toString()]
        running: false
    }
}
