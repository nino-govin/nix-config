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
    property var  audio:   null
    property var  brightness: null
    property var  bluetooth: null
    property var  media:     null
    property var  wifi:      null
    signal panelClosed
    signal openPowerMenu
    signal openWifiPopup
    signal openBtPopup

    WlrLayershell.namespace:     "quickshell-qs"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: open

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.panelClosed()

        Rectangle {
            anchors.fill: parent
            color: "#3a000000"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.panelClosed()
        }
    }

    Rectangle {
        id: _panel
        anchors { top: parent.top; right: parent.right; topMargin: 38; rightMargin: 12 }
        width:         Tokens.size.qsW
        implicitHeight: _col.implicitHeight + 28
        radius: Tokens.radius.xl5
        color:  Tokens.color.modalBg
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
                    sublabel: !(root.wifi?.available ?? false) ? "Indisponible"
                            : (root.wifi?.enabled ?? false)
                                ? ((root.wifi?.activeSsid ?? "") !== "" ? root.wifi.activeSsid : "Activé")
                                : "Désactivé"
                    active:     root.wifi?.enabled ?? false
                    expandable: root.wifi?.available ?? false
                    onToggled: if (root.wifi?.available) root.wifi.toggle()
                    onExpand:  root.openWifiPopup()
                }
                ToggleTile {
                    width: (parent.width - 10) / 2
                    iconName: "bluetooth"
                    label:    "Bluetooth"
                    sublabel: !(root.bluetooth?.available ?? false) ? "Indisponible"
                            : (root.bluetooth?.powered ?? false)
                                ? ((root.bluetooth?.connectedCount ?? 0) > 0
                                    ? (root.bluetooth.connectedCount + " connecté" + (root.bluetooth.connectedCount > 1 ? "s" : ""))
                                    : "Activé")
                                : "Désactivé"
                    active:     root.bluetooth?.powered ?? false
                    expandable: root.bluetooth?.available ?? false
                    onToggled: if (root.bluetooth?.available) root.bluetooth.togglePower()
                    onExpand:  root.openBtPopup()
                }
            }

            SliderRow {
                width: parent.width
                iconName: "sun"
                barColor: Tokens.color.yellow
                value:    root.brightness?.value ?? 0
                minValue: 0.05
                onMoved: v => root.brightness?.setValue(v)
            }
            SliderRow {
                width: parent.width
                iconName: "music"
                barColor: Tokens.color.blue
                value:    root.audio?.volume ?? 0
                muted:    root.audio?.muted ?? false
                iconClickable: true
                onMoved: v => root.audio?.setVolume(v)
                onIconClicked: root.audio?.toggleMute()
            }

            Rectangle {
                visible: root.media?.available ?? false
                width: parent.width
                height: 1
                color: Tokens.color.separator
            }

            MediaPlayer {
                visible: root.media?.available ?? false
                width: parent.width
                media: root.media
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

            Row {
                spacing: 4
                bottomPadding: 2

                Icon {
                    visible: root.battery?.charging ?? false
                    icon:    "zap"
                    size:    Tokens.font.xs
                    color:   Tokens.color.cyan
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text:           "Batterie " + (root.battery?.percent ?? "—") + "%" + ((root.battery?.charging ?? false) ? " — charge" : "")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color: (root.battery?.charging ?? false) ? Tokens.color.cyan :
                           (root.battery?.percent ?? 100) < 20 ? Tokens.color.red :
                           (root.battery?.percent ?? 100) < 50 ? Tokens.color.orange :
                           (root.battery?.percent ?? 100) < 80 ? Tokens.color.yellow :
                           Tokens.color.fg4
                    anchors.verticalCenter: parent.verticalCenter
                }
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
