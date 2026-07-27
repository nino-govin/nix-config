import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../widgets"

PanelWindow {
    id: root

    property bool open: false
    signal panelClosed

    WlrLayershell.namespace:     "quickshell-powermenu"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { left: true; right: true; top: true; bottom: true }
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

        MouseArea { anchors.fill: parent; onClicked: root.panelClosed() }

        Rectangle {
            anchors.centerIn: parent
            width:  560
            height: 158
            radius: Tokens.radius.xl6
            color:  Tokens.color.modalBg
            border.color: Tokens.color.borderNorm
            border.width: 1

            MouseArea { 
                anchors.fill: parent
            }

            Row {
                anchors.centerIn: parent
                spacing: 10

                PowerAction {
                    iconName: "lock";    label: "Verrouiller"
                    onTriggered: { root.panelClosed(); _run("hyprlock") }
                }
                PowerAction {
                    iconName: "logout";  label: "Déconnexion"
                    onTriggered: { root.panelClosed(); _run("hyprctl dispatch exit") }
                }
                PowerAction {
                    iconName: "restart"; label: "Redémarrer"
                    onTriggered: { root.panelClosed(); _run("systemctl reboot") }
                }
                PowerAction {
                    iconName: "suspend"; label: "Suspendre"
                    onTriggered: { root.panelClosed(); _run("systemctl suspend") }
                }
                PowerAction {
                    iconName: "power"; label: "Éteindre"; primary: true
                    onTriggered: { root.panelClosed(); _run("systemctl poweroff") }
                }
            }
        }
    }

    Process {
        id: _pmProc
        running: false
    }
    function _run(cmd) {
        _pmProc.command = ["bash", "-c", cmd]
        _pmProc.running = true
    }
}
