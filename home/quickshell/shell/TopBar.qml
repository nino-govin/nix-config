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
    WlrLayershell.exclusiveZone: 0
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

        Item {
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            height: parent.height

            Row {
                id: _speedRow
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                spacing: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "↓" + (topbar.network?.downStr ?? "—")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          Tokens.color.green
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "↑" + (topbar.network?.upStr ?? "—")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          Tokens.color.netUp
                }
            }

            Rectangle {
                id: _netSep
                width: 1; height: 12
                x: _speedRow.x - 10 - width
                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                anchors.verticalCenter: parent.verticalCenter
                color: Tokens.color.borderNorm
            }

            Text {
                x: _netSep.x - 10 - implicitWidth
                anchors.verticalCenter: parent.verticalCenter
                text:           topbar.network?.ip ?? "—"
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg4
            }
        }
    }
}
