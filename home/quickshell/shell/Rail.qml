import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../widgets"

PanelWindow {
    id: rail

    property var hyprland: null
    property var battery:  null
    property var sysInfo:  null

    property bool qsVisible: false
    signal qsToggled(bool visible)

    WlrLayershell.namespace:     "quickshell-rail"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: Tokens.size.railW
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors { left: true; top: true; bottom: true }
    implicitWidth: Tokens.size.railW
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color:        Tokens.color.railBg
        border.color: Tokens.color.railBorder
        border.width: 1

        Item {
            id: _inner
            anchors {
                top: parent.top; bottom: parent.bottom
                left: parent.left; right: parent.right
                topMargin: 6; bottomMargin: 14
            }

            Column {
                id: topSection
                anchors { top: parent.top; left: parent.left; right: parent.right }
                spacing: 14

                Column {
                    width: parent.width
                    spacing: Tokens.spacing.tileGap

                    Repeater {
                        model: 5
                        Item {
                            width: parent.width
                            height: Tokens.size.tile
                            WorkspaceTile {
                                anchors.centerIn: parent
                                wsId:     modelData + 1
                                active:   rail.hyprland?.activeWorkspace === (modelData + 1)
                                hyprland: rail.hyprland
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 26; height: 1
                    color: Tokens.color.separator
                }

                Column {
                    width: parent.width
                    spacing: 10

                    Item {
                        width: parent.width; height: 32
                        AppTile {
                            anchors.centerIn: parent
                            iconPath: "/etc/profiles/per-user/nino-nixos/share/icons/hicolor/128x128/apps/firefox.png"
                            appCmd:   "firefox"
                        }
                    }
                    Item {
                        width: parent.width; height: 32
                        AppTile {
                            anchors.centerIn: parent
                            iconPath: "/run/current-system/sw/share/icons/hicolor/256x256/apps/discord.png"
                            appCmd:   "discord"
                        }
                    }
                    Item {
                        width: parent.width; height: 32
                        AppTile {
                            anchors.centerIn: parent
                            iconPath: "/run/current-system/sw/share/icons/hicolor/256x256/apps/kitty.png"
                            appCmd:   "kitty"
                        }
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 26; height: 1
                    color: Tokens.color.separator
                }

                Column {
                    width: parent.width
                    spacing: 26

                    GaugeStat {
                        width: parent.width
                        label:    "CPU"
                        value:    (rail.sysInfo?.cpuPercent ?? 0) + "%"
                        sub:      rail.sysInfo?.cpuTemp ?? "—"
                        percent:  rail.sysInfo?.cpuPercent ?? 0
                        barColor: Tokens.color.blue
                    }
                    GaugeStat {
                        width: parent.width
                        label:    "GPU"
                        value:    (rail.sysInfo?.gpuPercent ?? 0) + "%"
                        sub:      rail.sysInfo?.gpuTemp ?? "—"
                        percent:  rail.sysInfo?.gpuPercent ?? 0
                        barColor: Tokens.color.green
                    }
                    GaugeStat {
                        width: parent.width
                        label:    "RAM"
                        value:    rail.sysInfo?.ramUsed ?? "—"
                        sub:      "/" + (rail.sysInfo?.ramTotal ?? "—")
                        percent:  rail.sysInfo?.ramPercent ?? 0
                        barColor: Tokens.color.yellow
                    }
                }
            }

            Column {
                id: bottomSection
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           rail.hyprland?.keyboardLayout ?? "FR"
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.chip
                    font.weight:    Font.DemiBold
                    color:          Tokens.color.fg3
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 3

                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Tokens.size.battW; height: Tokens.size.battH

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color:  "#00000000"
                            border.color: Tokens.color.fg4
                            border.width: 1

                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 1 }
                                width: (parent.width - 2) *
                                       Math.max(0, Math.min(1, (rail.battery?.percent ?? 0) / 100))
                                radius: 2
                                color: (rail.battery?.percent ?? 100) < 20
                                       ? Tokens.color.red : Tokens.color.green
                                Behavior on width { NumberAnimation { duration: 500 } }
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           (rail.battery?.percent ?? 0) + "%"
                        font.family:    Tokens.font.sans
                        font.pixelSize: Tokens.font.badge
                        color:          Tokens.color.fg3
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 34; height: 34

                    Rectangle {
                        anchors.fill: parent
                        radius: Tokens.radius.lg
                        color: _qsArea.containsMouse ? Tokens.color.itemBg : "#00000000"
                        border.color: Tokens.color.borderStr
                        border.width: 1
                    }

                    Icon {
                        anchors.centerIn: parent
                        icon:  "menu"
                        size:  Tokens.size.iconLg
                        color: Tokens.color.fg3
                    }

                    MouseArea {
                        id: _qsArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: rail.qsToggled(!rail.qsVisible)
                    }
                }
            }
        }
    }
}
