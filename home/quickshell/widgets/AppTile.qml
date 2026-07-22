import QtQuick
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    property string iconPath: ""
    property string appCmd:   ""

    implicitWidth:  32
    implicitHeight: 32
    radius: Tokens.radius.lg
    color:  _hover ? Tokens.color.itemBg : "transparent"

    scale: _hover ? 1.08 : 1.0
    Behavior on scale { NumberAnimation { duration: 120 } }
    property bool _hover: false

    Image {
        anchors.centerIn: parent
        width: 24; height: 24
        source: root.iconPath
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    HoverHandler { onHoveredChanged: root._hover = hovered }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.appCmd !== "") _proc.running = true
    }

    Process {
        id: _proc
        command: ["bash", "-c", root.appCmd + " &"]
        running: false
    }
}
