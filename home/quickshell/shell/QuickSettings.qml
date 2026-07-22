import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../widgets"

PanelWindow {
    id: root

    property bool open:    false
    property var  battery: null
    property var  network: null
    signal panelClosed
    signal openPowerMenu

    WlrLayershell.namespace:     "quickshell-qs"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { right: true; top: true }
    implicitWidth:  Tokens.size.qsW + 16
    implicitHeight: _panel.implicitHeight + 24
    color: "transparent"
    visible: open

    function close() { open = false; root.panelClosed() }

    Keys.onEscapePressed: close()

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: _panel
        anchors { top: parent.top; right: parent.right; topMargin: 12; rightMargin: 12 }
        width:  Tokens.size.qsW
        implicitHeight: _col.implicitHeight + 28
        radius: Tokens.radius.xl5
        color:  Tokens.color.panelBg
        border.color: Tokens.color.borderNorm
        border.width: 1

        MouseArea { anchors.fill: parent }

        Column {
            id: _col
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
            spacing: 12

            Row {
                width: parent.width
                height: 46

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text:           "Bonjour"
                        font.family:    Tokens.font.sans
                        font.pixelSize: Tokens.font.lg
                        font.weight:    Font.DemiBold
                        color:          Tokens.color.fg0
                    }
                    Text {
                        text:           _username
                        font.family:    Tokens.font.sans
                        font.pixelSize: Tokens.font.xs
                        color:          Tokens.color.fg4
                    }
                }
                Item { width: parent.width - parent.children[0].width - 24; height: 1 }
                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon:  "power"
                    size:  19
                    color: Tokens.color.fg2
                    strokeWidth: 1.8
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: { root.close(); root.openPowerMenu() }
                    }
                }
            }

            Grid {
                width: parent.width
                columns: 2
                columnSpacing: 10
                rowSpacing:    10

                ToggleTile {
                    width: (parent.width - 10) / 2
                    iconName: "wifi"
                    label:    "Wi-Fi"
                    sublabel: root.network?.ssid ?? "—"
                    active:   true
                }
                ToggleTile {
                    width: (parent.width - 10) / 2
                    iconName: "bluetooth"
                    label:    "Bluetooth"
                    sublabel: "Désactivé"
                    active:   false
                }
            }

            SliderRow {
                width: parent.width
                iconName: "sun";   barColor: Tokens.color.yellow; value: 0.64
                onMoved: v => _runCmd("brightnessctl set " + Math.round(v * 100) + "%")
            }
            SliderRow {
                width: parent.width
                iconName: "music"; barColor: Tokens.color.blue; value: 0.78
                onMoved: v => _runCmd("pactl set-sink-volume @DEFAULT_SINK@ " + Math.round(v * 100) + "%")
            }

            Rectangle { width: parent.width; height: 1; color: Tokens.color.separator }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text:           "Notifications"
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    font.weight:    Font.DemiBold
                    color:          Tokens.color.fg3
                }
                Text {
                    text:           "Aucune notification"
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          Tokens.color.fg5
                }
            }

            Rectangle { width: parent.width; height: 1; color: Tokens.color.separator }

            Text {
                text:           "Batterie " + (root.battery?.percent ?? "—") + "%"
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg4
                bottomPadding:  2
            }
        }
    }

    property string _username: "utilisateur"
    Process {
        command: ["bash", "-c", "echo $USER"]
        running: true
        stdout: SplitParser {
            onRead: data => { _username = data.trim() }
        }
    }

    Process {
        id: _cmdProc
        running: false
    }
    function _runCmd(cmd) {
        _cmdProc.command = ["bash", "-c", cmd]
        _cmdProc.running = true
    }
}
