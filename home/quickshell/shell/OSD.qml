import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../widgets"

PanelWindow {
    id: root

    property var audio: null
    property var brightness: null

    property string _kind: "volume"
    property real _value: 0
    property bool _muted: false
    property bool _visible: false

    WlrLayershell.namespace:     "quickshell-osd"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { bottom: true }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth:  260
    implicitHeight: 60
    margins.bottom: 80
    color: "transparent"
    visible: _visible

    property bool _armed: false
    Component.onCompleted: Qt.callLater(() => _armed = true)

    Connections {
        target: root.audio
        function onChanged() {
            if (!root._armed) return
            root._kind  = "volume"
            root._value = root.audio.volume
            root._muted = root.audio.muted
            _show()
        }
    }

    Connections {
        target: root.brightness
        function onChanged() {
            if (!root._armed) return
            root._kind  = "brightness"
            root._value = root.brightness.value
            root._muted = false
            _show()
        }
    }

    function _show() {
        root._visible = true
        _hideT.restart()
    }

    Timer {
        id: _hideT
        interval: 1500
        repeat: false
        onTriggered: root._visible = false
    }

    Rectangle {
        id: _bg
        anchors.fill: parent
        radius: Tokens.radius.xl3
        color:  Tokens.color.modalBg
        border.color: Tokens.color.borderNorm
        border.width: 1
        opacity: root._visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Row {
            anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
            spacing: 14

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                icon:
                    root._kind === "brightness" ? "sun" :
                    root._muted                 ? "speaker" :
                                                  "music"
                size:  Tokens.size.iconXl2
                color:
                    root._kind === "brightness" ? Tokens.color.yellow :
                    root._muted                 ? Tokens.color.fg4    :
                                                  Tokens.color.blue
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width:  parent.width - Tokens.size.iconXl2 - 14 - _pctLbl.width - 14
                height: 8

                Rectangle {
                    anchors.fill: parent
                    radius: Tokens.radius.sm
                    color:  Tokens.color.trackBg
                }
                Rectangle {
                    width:  parent.width * Math.max(0, Math.min(1, root._value))
                    height: parent.height
                    radius: Tokens.radius.sm
                    color:  root._kind === "brightness" ? Tokens.color.yellow :
                            root._muted                 ? Tokens.color.fg4    :
                                                          Tokens.color.blue
                    Behavior on width { NumberAnimation { duration: 120 } }
                }
            }

            Text {
                id: _pctLbl
                anchors.verticalCenter: parent.verticalCenter
                width:          36
                text:           root._muted && root._kind === "volume"
                                    ? "OFF"
                                    : Math.round(root._value * 100) + "%"
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.sm
                font.weight:    Font.DemiBold
                color:          Tokens.color.fg0
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
