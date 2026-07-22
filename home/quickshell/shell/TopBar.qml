import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: topbar

    property var clock:    null
    property var network:  null
    property var hyprland: null

    WlrLayershell.namespace:     "quickshell-topbar"
    WlrLayershell.layer:         WlrLayer.Top
    WlrLayershell.exclusiveZone: Tokens.size.topbarH
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { left: true; right: true; top: true }
    implicitHeight: Tokens.size.topbarH
    color: "transparent"

    Rectangle {
        id: _bg
        anchors.fill: parent
        color:        Tokens.color.topbarBg
        border.color: Tokens.color.topbarBorder
        border.width: 0

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: Tokens.color.topbarBorder
        }

        Text {
            anchors {
                left: parent.left; leftMargin: Tokens.size.railW + 14
                verticalCenter: parent.verticalCenter
            }
            text:           topbar.hyprland?.activeTitle ?? ""
            font.family:    Tokens.font.sans
            font.pixelSize: Tokens.font.xs
            font.italic:    true
            color:          Tokens.color.fg3
            elide:          Text.ElideRight
            width:          parent.width / 4
        }

        Row {
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           topbar.clock?.time ?? "--:--"
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg0
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           "/"
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg5
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           topbar.clock?.date ?? ""
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg4
            }
        }

        Row {
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           topbar.network?.ip ?? "—"
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg4
            }
            Rectangle {
                width: 1; height: 12
                anchors.verticalCenter: parent.verticalCenter
                color: Tokens.color.borderNorm
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text:           "↓" + (topbar.network?.downStr ?? "—")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          Tokens.color.green
                }
                Text {
                    text:           "↑" + (topbar.network?.upStr ?? "—")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          Tokens.color.netUp
                }
            }
        }
    }
}
