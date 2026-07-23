import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
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
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors { left: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Tokens.size.railW
    color: "transparent"

    property var _wsItems: [{id: 1, ellipsis: false}]

    function _rebuildWs() {
        const vals = Hyprland.workspaces?.values
        if (!vals) return
        const arr = []
        for (let i = 0; i < vals.length; i++) arr.push({id: vals[i].id})
        arr.sort((a, b) => a.id - b.id)
        if (arr.length === 0) { _wsItems = [{id: 1, ellipsis: false}]; return }
        if (arr.length <= 5) { _wsItems = arr.map(w => ({id: w.id, ellipsis: false})); return }
        if (arr.length <= 6) { _wsItems = arr.slice(0, 5).map(w => ({id: w.id, ellipsis: false})); return }
        _wsItems = [
            {id: arr[0].id,              ellipsis: false},
            {id: arr[1].id,              ellipsis: false},
            {id: -1,                     ellipsis: true},
            {id: arr[arr.length-2].id,   ellipsis: false},
            {id: arr[arr.length-1].id,   ellipsis: false},
        ]
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { rail._rebuildWs() }
    }

    Component.onCompleted: _rebuildWs()

    Rectangle {
        anchors.fill: parent
        color: Tokens.color.railBg

        Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            width: 1
            color: Tokens.color.railBorder
        }

        Item {
            id: _inner
            anchors {
                top: parent.top; bottom: parent.bottom
                left: parent.left; right: parent.right
                topMargin: 14; bottomMargin: 14
            }

            Item {
                id: topSection
                anchors { top: parent.top; left: parent.left; right: parent.right }

                Item {
                    id: _wsContainer
                    width: parent.width
                    y: 0
                    height: rail._wsItems.length * Tokens.size.tile +
                            Math.max(0, rail._wsItems.length - 1) * Tokens.spacing.tileGap
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Column {
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        spacing: Tokens.spacing.tileGap

                        Repeater {
                            model: rail._wsItems
                            Item {
                                width: parent.width
                                height: Tokens.size.tile

                                Text {
                                    visible: modelData.ellipsis
                                    anchors.centerIn: parent
                                    text: "…"
                                    font.family:    Tokens.font.sans
                                    font.pixelSize: Tokens.font.xs
                                    color: Tokens.color.fg4
                                }
                                WorkspaceTile {
                                    visible: !modelData.ellipsis
                                    anchors.centerIn: parent
                                    wsId:   modelData.id
                                    active: (Hyprland.focusedWorkspace?.id ?? -1) === modelData.id
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: _topSep
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: _wsContainer.height + 14
                    width: 26; height: 1
                    color: Tokens.color.separator
                }

                Column {
                    id: _appsSection
                    anchors { left: parent.left; right: parent.right }
                    y: _topSep.y + 1 + 14
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
            }

            Column {
                id: bottomSection
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                spacing: 10

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 26; height: 1
                    color: Tokens.color.separator
                }

                Column {
                    width: parent.width
                    spacing: 18

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

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 26; height: 1
                    color: Tokens.color.separator
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           rail.hyprland?.keyboardLayout ?? "FR"
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.sm
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
                        font.pixelSize: Tokens.font.xs
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
