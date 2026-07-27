import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../widgets"

PanelWindow {
    id: root
    property bool open: false
    property var wifi: null
    signal panelClosed

    WlrLayershell.namespace:     "quickshell-wifipopup"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    visible: open

    property string _selectedSsid: ""
    property string _password: ""
    property bool   _pwPrompt: false

    readonly property bool _hasWifi: root.wifi?.available ?? false
    readonly property bool _wifiOn: root.wifi?.enabled ?? false

    onOpenChanged: {
        if (open) {
            _pwPrompt = false
            _selectedSsid = ""
            _password = ""
            root.wifi?.rescan()
        }
    }

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
            if (_pwPrompt) return base + 150
            if (!_hasWifi) return base + 60
            if (!_wifiOn)  return base + 80
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
                        icon: "wifi"; size: 22; color: Tokens.color.fg2; strokeWidth: 1.8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Wi-Fi"
                        font.family: Tokens.font.sans
                        font.pixelSize: Tokens.font.lg
                        font.weight: Font.DemiBold
                        color: Tokens.color.fg0
                    }
                }

                Switch {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    checked: _wifiOn
                    enabled: _hasWifi
                    onColor: Tokens.color.blue
                    onToggled: if (_hasWifi) root.wifi.toggle()
                }
            }

            Rectangle {
                visible: !_hasWifi
                width: parent.width
                height: 60
                radius: Tokens.radius.xl3
                color:  Tokens.color.bg2
                border.color: Tokens.color.borderFaint
                border.width: 1
                opacity: 0.7

                Text {
                    anchors.centerIn: parent
                    text: "NetworkManager indisponible"
                    font.family: Tokens.font.sans
                    font.pixelSize: Tokens.font.sm
                    color: Tokens.color.fg4
                }
            }

            Rectangle {
                visible: _hasWifi && !_wifiOn
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
                        text: "Wi-Fi désactivé"
                        font.family: Tokens.font.sans
                        font.pixelSize: Tokens.font.md
                        font.weight: Font.DemiBold
                        color: Tokens.color.fg3
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Activez le Wi-Fi pour voir les réseaux disponibles"
                        font.family: Tokens.font.sans
                        font.pixelSize: Tokens.font.xs
                        color: Tokens.color.fg4
                    }
                }
            }

            Rectangle {
                visible: _hasWifi && _wifiOn && !_pwPrompt
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
                            text: "Réseaux disponibles"
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
                                color: _rescanArea.containsMouse ? Tokens.color.itemBg : "transparent"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }
                            Icon {
                                anchors.centerIn: parent
                                icon: "refresh"; size: 14; color: Tokens.color.fg3
                                strokeWidth: 1.8
                                RotationAnimator on rotation {
                                    running: root.wifi?.scanning ?? false
                                    loops:   Animation.Infinite
                                    from:    0
                                    to:      360
                                    duration: 800
                                }
                            }
                            MouseArea {
                                id: _rescanArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.wifi?.rescan()
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
                        model: root.wifi?.networks ?? []
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        topMargin: 6
                        bottomMargin: 6
                        leftMargin: 8
                        rightMargin: 8

                        delegate: Rectangle {
                            width:  ListView.view.width - 16
                            height: 56
                            radius: Tokens.radius.lg
                            color:  _netArea.containsMouse ? Tokens.color.itemBg : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 12

                                Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    icon: "wifi"
                                    size: 20
                                    color: modelData.inUse ? Tokens.color.blue :
                                           modelData.signal > 60 ? Tokens.color.fg2 :
                                           modelData.signal > 30 ? Tokens.color.fg3 : Tokens.color.fg4
                                    opacity: modelData.signal > 60 ? 1.0 : modelData.signal > 30 ? 0.8 : 0.55
                                    strokeWidth: 1.8
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 90
                                    spacing: 3

                                    Text {
                                        text: modelData.ssid
                                        font.family: Tokens.font.sans
                                        font.pixelSize: Tokens.font.md
                                        font.weight: modelData.inUse ? Font.DemiBold : Font.Medium
                                        color: modelData.inUse ? Tokens.color.blue : Tokens.color.fg0
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                    Text {
                                        text: modelData.inUse
                                            ? "Connecté · " + (modelData.security || "Ouvert")
                                            : (modelData.security || "Ouvert")
                                        font.family: Tokens.font.sans
                                        font.pixelSize: Tokens.font.xs
                                        color: Tokens.color.fg4
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.signal + "%"
                                    font.family: Tokens.font.sans
                                    font.pixelSize: Tokens.font.sm
                                    font.weight: Font.Medium
                                    color: Tokens.color.fg3
                                }
                            }

                            MouseArea {
                                id: _netArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.inUse) {
                                        root.wifi?.disconnect()
                                    } else if (modelData.security !== "") {
                                        root._selectedSsid = modelData.ssid
                                        root._pwPrompt = true
                                        Qt.callLater(() => _pwField.forceActiveFocus())
                                    } else {
                                        root.wifi?.connect(modelData.ssid, "")
                                        root.panelClosed()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Column {
                visible: _pwPrompt
                width: parent.width
                spacing: 14

                Text {
                    text: "Connexion à « " + _selectedSsid + " »"
                    font.family: Tokens.font.sans
                    font.pixelSize: Tokens.font.md
                    font.weight: Font.DemiBold
                    color: Tokens.color.fg0
                }

                Rectangle {
                    width: parent.width
                    height: 44
                    radius: Tokens.radius.lg
                    color: Tokens.color.bg2
                    border.color: Tokens.color.borderFaint
                    border.width: 1

                    TextField {
                        id: _pwField
                        anchors.fill: parent
                        anchors.margins: 4
                        anchors.leftMargin: 14
                        background: Item {}
                        placeholderText: "Mot de passe"
                        color: Tokens.color.fg0
                        placeholderTextColor: Tokens.color.fg5
                        font.family: Tokens.font.sans
                        font.pixelSize: Tokens.font.sm
                        echoMode: TextInput.Password
                        selectByMouse: true
                        onTextChanged: root._password = text
                        Keys.onEscapePressed: root._pwPrompt = false
                        Keys.onReturnPressed: {
                            root.wifi?.connect(root._selectedSsid, root._password)
                            root.panelClosed()
                        }
                        Keys.onEnterPressed: {
                            root.wifi?.connect(root._selectedSsid, root._password)
                            root.panelClosed()
                        }
                    }
                }

                Row {
                    spacing: 8
                    layoutDirection: Qt.RightToLeft
                    width: parent.width

                    Rectangle {
                        width: 110; height: 34
                        radius: Tokens.radius.lg
                        color: Tokens.color.blue
                        Text {
                            anchors.centerIn: parent
                            text: "Connecter"
                            font.family: Tokens.font.sans
                            font.pixelSize: Tokens.font.sm
                            font.weight: Font.DemiBold
                            color: Tokens.color.bg0
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.wifi?.connect(root._selectedSsid, root._password)
                                root.panelClosed()
                            }
                        }
                    }
                    Rectangle {
                        width: 90; height: 34
                        radius: Tokens.radius.lg
                        color: Tokens.color.itemBg
                        Text {
                            anchors.centerIn: parent
                            text: "Annuler"
                            font.family: Tokens.font.sans
                            font.pixelSize: Tokens.font.sm
                            color: Tokens.color.fg2
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root._pwPrompt = false
                        }
                    }
                }
            }
        }
    }
}
