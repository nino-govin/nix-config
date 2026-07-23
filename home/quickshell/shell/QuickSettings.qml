import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Effects
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

    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: open

    Keys.onEscapePressed: root.panelClosed()

    MouseArea {
        anchors.fill: parent
        onClicked: root.panelClosed()
    }

    Rectangle {
        id: _panel
        anchors { top: parent.top; right: parent.right; topMargin: 12; rightMargin: 12 }
        width:         Tokens.size.qsW
        implicitHeight: _col.implicitHeight + 28
        radius: Tokens.radius.xl5
        color:  Tokens.color.panelBg
        border.color: Tokens.color.borderNorm
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled:           true
            shadowColor:             "#CC000000"
            shadowVerticalOffset:    4
            shadowHorizontalOffset: -4
            shadowBlur:              2.5
        }

        MouseArea { anchors.fill: parent }

        Column {
            id: _col
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
            spacing: 12

            Item {
                width: parent.width
                height: 46

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text:           "Bonjour, " + _username
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.lg
                    font.weight:    Font.DemiBold
                    color:          Tokens.color.fg0
                    elide:          Text.ElideRight
                    width:          parent.width - _powerIcon.implicitWidth - 16
                }

                Icon {
                    id: _powerIcon
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    icon:  "power"
                    size:  19
                    color: Tokens.color.fg2
                    strokeWidth: 1.8
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: root.openPowerMenu()
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
                iconName: "sun";   barColor: Tokens.color.yellow; value: 0.64; minValue: 0.05
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
