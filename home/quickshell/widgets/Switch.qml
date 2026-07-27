import QtQuick
import "../theme"

Item {
    id: root
    property bool checked: false
    property bool enabled: true
    property color onColor: Tokens.color.blue

    signal toggled(bool checked)

    implicitWidth:  40
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.onColor : Tokens.color.bg3
        opacity: root.enabled ? 1 : 0.5
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Rectangle {
        width: parent.height - 4
        height: width
        radius: width / 2
        y: 2
        x: root.checked ? (parent.width - width - 2) : 2
        color: root.checked ? Tokens.color.bg0 : Tokens.color.fg2
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
