import QtQuick
import "../theme"

Rectangle {
    id: root

    property string currentMode: "balanced"
    signal modeSelected(string mode)

    readonly property var _modes: [
        { id: "performance", label: "Performance", icon: "zap",  color: Tokens.color.yellow },
        { id: "balanced",    label: "Équilibré",   icon: "sun",  color: Tokens.color.blue   },
        { id: "economy",     label: "Économie",    icon: "moon", color: Tokens.color.green  }
    ]

    readonly property var _current: {
        for (let m of _modes) if (m.id === currentMode) return m
        return _modes[1]
    }

    implicitHeight: _inner.implicitHeight + 20
    radius: Tokens.radius.xl3
    color:  Tokens.color.itemBg
    border.color: Tokens.color.borderSub
    border.width: 1

    Column {
        id: _inner
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 10

        Row {
            spacing: 8

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                icon:  root._current.icon
                size:  Tokens.size.iconXl
                color: root._current.color
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text:           "Profil d'énergie"
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.sm
                    font.weight:    Font.DemiBold
                    color:          Tokens.color.fg2
                }
                Text {
                    text:           root._current.label
                    font.family:    Tokens.font.sans
                    font.pixelSize: 9
                    color:          root._current.color
                }
            }
        }

        Row {
            width:   parent.width
            spacing: 6

            Repeater {
                model: root._modes

                delegate: Rectangle {
                    width:  (parent.width - 12) / 3
                    height: 28
                    radius: Tokens.radius.xl2

                    readonly property bool _active: root.currentMode === modelData.id

                    color: _active
                        ? Qt.rgba(
                            modelData.color.r,
                            modelData.color.g,
                            modelData.color.b,
                            0.22)
                        : Tokens.color.bg1
                    border.color: _active ? modelData.color : "transparent"
                    border.width: 1

                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            icon:  modelData.icon
                            size:  11
                            color: _active ? modelData.color : Tokens.color.fg4
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           modelData.label
                            font.family:    Tokens.font.sans
                            font.pixelSize: 10
                            font.weight:    _active ? Font.DemiBold : Font.Normal
                            color:          _active ? modelData.color : Tokens.color.fg4
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.modeSelected(modelData.id)
                    }
                }
            }
        }
    }
}
