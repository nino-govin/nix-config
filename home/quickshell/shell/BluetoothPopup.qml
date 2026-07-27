import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../widgets"

PanelWindow {
    id: root
    property bool open: false
    property var bluetooth: null
    signal panelClosed

    WlrLayershell.namespace:     "quickshell-btpopup"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    visible: open

    readonly property bool _hasBt: root.bluetooth?.available ?? false
    readonly property bool _btOn:  root.bluetooth?.powered ?? false

    onOpenChanged: if (open) root.bluetooth?.refresh()

    Item {
        anchors.fill: parent
        focus: root.open
        Keys.onEscapePressed: root.panelClosed()

        Rectangle {
            anchors.fill: parent
            color: "#66000000"
            MouseArea { anchors.fill: parent; onClicked: root.panelClosed() }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width:  480
        height: {
            const base = 40 + 28 + 16
            if (!_hasBt) return base + 60
            if (!_btOn)  return base + 80
            return base + 440
        }
        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        radius: Tokens.radius.xl5
        color:  Tokens.color.modalBg
        border.color: Tokens.color.borderNorm
        border.width: 1
        clip: true

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled:        true
            shadowColor:          "#CC000000"
            shadowVerticalOffset: 8
            shadowBlur:           2.0
        }

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Item {
                width: parent.width
                height: 28

                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    spacing: 10

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "bluetooth"; size: 22; color: Tokens.color.fg2; strokeWidth: 1.8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Bluetooth"
                        font.family: Tokens.font.sans
                        font.pixelSize: Tokens.font.lg
                        font.weight: Font.DemiBold
                        color: Tokens.color.fg0
                    }
                }

                Switch {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    checked: _btOn
                    enabled: _hasBt
                    onColor: Tokens.color.blue
                    onToggled: if (_hasBt) root.bluetooth.togglePower()
                }
            }

            Rectangle {
                visible: !_hasBt
                width: parent.width
                height: 60
                radius: Tokens.radius.xl3
                color:  Tokens.color.bg2
                border.color: Tokens.color.borderFaint
                border.width: 1
                opacity: 0.7

                Text {
                    anchors.centerIn: parent
                    text: "Bluetooth indisponible (bluetoothctl absent)"
                    font.family: Tokens.font.sans
                    font.pixelSize: Tokens.font.sm
                    color: Tokens.color.fg4
                }
            }

            Rectangle {
                visible: _hasBt && !_btOn
                width: parent.width
                height: 80
                radius: Tokens.radius.xl3
                color:  Tokens.color.bg2
                border.color: Tokens.color.borderFaint
                border.width: 1
                opacity: 0.6

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Bluetooth désactivé"
                        font.family: Tokens.font.sans
                        font.pixelSize: Tokens.font.md
                        font.weight: Font.DemiBold
                        color: Tokens.color.fg3
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Activez le Bluetooth pour voir les appareils"
                        font.family: Tokens.font.sans
                        font.pixelSize: Tokens.font.xs
                        color: Tokens.color.fg4
                    }
                }
            }

            Rectangle {
                visible: _hasBt && _btOn
                width: parent.width
                height: 440
                radius: Tokens.radius.xl3
                color:  Tokens.color.bg2
                border.color: Tokens.color.borderFaint
                border.width: 1

                Column {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        width: parent.width
                        height: 44

                        Text {
                            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                            text: "Appareils disponibles"
                            font.family: Tokens.font.sans
                            font.pixelSize: Tokens.font.sm
                            font.weight: Font.DemiBold
                            color: Tokens.color.fg2
                        }

                        Item {
                            anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                            width: 28; height: 28

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: _scanArea.containsMouse ? Tokens.color.itemBg : "transparent"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }
                            Icon {
                                anchors.centerIn: parent
                                icon: "refresh"; size: 14; color: Tokens.color.fg3
                                strokeWidth: 1.8
                                RotationAnimator on rotation {
                                    running: root.bluetooth?.scanning ?? false
                                    loops:   Animation.Infinite
                                    from:    0
                                    to:      360
                                    duration: 800
                                }
                            }
                            MouseArea {
                                id: _scanArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.bluetooth?.scan()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 1
                        color: Tokens.color.borderFaint
                    }

                    ListView {
                        width: parent.width
                        height: parent.height - 45
                        clip: true
                        model: root.bluetooth?.devices ?? []
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        topMargin: 6
                        bottomMargin: 6
                        leftMargin: 8
                        rightMargin: 8

                        delegate: Rectangle {
                            width:  ListView.view.width - 16
                            height: 60
                            radius: Tokens.radius.lg
                            color:  _devArea.containsMouse ? Tokens.color.itemBg : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 10
                                spacing: 12

                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: modelData.connected ? Tokens.color.green :
                                           modelData.paired    ? Tokens.color.yellow : Tokens.color.fg5
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 170
                                    spacing: 3

                                    Text {
                                        text: modelData.name
                                        font.family: Tokens.font.sans
                                        font.pixelSize: Tokens.font.md
                                        font.weight: modelData.connected ? Font.DemiBold : Font.Medium
                                        color: Tokens.color.fg0
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                    Text {
                                        text: (modelData.connected ? "Connecté · " : (modelData.paired ? "Appairé · " : "")) + modelData.mac
                                        font.family: Tokens.font.sans
                                        font.pixelSize: Tokens.font.xs
                                        color: Tokens.color.fg4
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    Rectangle {
                                        width: 78; height: 30
                                        radius: Tokens.radius.md
                                        color: modelData.connected ? Tokens.color.red :
                                               modelData.paired    ? Tokens.color.blue : Tokens.color.itemBg
                                        border.color: modelData.paired || modelData.connected ? "transparent" : Tokens.color.borderFaint
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.connected ? "Couper" : (modelData.paired ? "Connect" : "Appairer")
                                            font.family: Tokens.font.sans
                                            font.pixelSize: Tokens.font.xs
                                            font.weight: Font.DemiBold
                                            color: (modelData.connected || modelData.paired) ? Tokens.color.bg0 : Tokens.color.fg2
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData.connected)   root.bluetooth?.disconnectDevice(modelData.mac)
                                                else if (modelData.paired) root.bluetooth?.connectDevice(modelData.mac)
                                                else                       root.bluetooth?.pairDevice(modelData.mac)
                                            }
                                        }
                                    }

                                    Item {
                                        width: 26; height: 26
                                        visible: modelData.paired
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: 13
                                            color: _rmArea.containsMouse ? Tokens.color.itemBg : "transparent"
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }
                                        Icon {
                                            anchors.centerIn: parent
                                            icon: "trash"; size: 12; color: Tokens.color.fg4
                                            strokeWidth: 1.8
                                        }
                                        MouseArea {
                                            id: _rmArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.bluetooth?.removeDevice(modelData.mac)
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: _devArea
                                anchors.fill: parent
                                hoverEnabled: true
                                propagateComposedEvents: true
                                onClicked: (m) => m.accepted = false
                            }
                        }
                    }
                }
            }
        }
    }
}
