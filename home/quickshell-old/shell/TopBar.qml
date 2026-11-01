import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"
import "../widgets"

PanelWindow {
    id: topbar

    property var clock:    null
    property var network:  null
    property var hyprland: null
    property var audio:    null

    property var _myMonitor: {
        if (!screen) return null
        const mons = Hyprland.monitors?.values
        if (!mons) return null
        for (let i = 0; i < mons.length; i++) {
            if (mons[i].name === screen.name) return mons[i]
        }
        return null
    }

    visible: !(_myMonitor?.activeWorkspace?.hasFullscreen ?? false)

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
            id: _titleText
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

            Tooltip {
                text: (topbar.hyprland?.activeClass ?? "") !== ""
                    ? (topbar.hyprland?.activeClass ?? "") + "\n" + (topbar.hyprland?.activeTitle ?? "")
                    : (topbar.hyprland?.activeTitle ?? "")
                side: "bottom"
            }
        }

        Row {
            id: _clockRow
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           topbar.clock?.time ?? "--:--"
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg0

                Tooltip {
                    text: (topbar.clock?.time ?? "--:--") + " (" + (topbar.clock?.timezone ?? "—") + ")\n" +
                          "Uptime: " + (topbar.clock?.uptime ?? "—")
                    side: "bottom"
                }
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

                Tooltip {
                    text: (topbar.clock?.dayOfWeek ?? "—") + "\n" +
                          "Semaine ISO " + (topbar.clock?.isoWeek ?? 0) + "\n" +
                          (topbar.clock?.dateShort ?? "—")
                    side: "bottom"
                }
            }
        }

        Row {
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            height: parent.height
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           topbar.network?.ip ?? "—"
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color:          Tokens.color.fg4

                Tooltip {
                    text: "Interface: " + (topbar.network?.iface ?? "—") +
                          ((topbar.network?.ssid ?? "—") !== "—" ? " • SSID: " + topbar.network.ssid : "") + "\n" +
                          "IP: " + (topbar.network?.ip ?? "—") + "\n" +
                          "Gateway: " + (topbar.network?.gateway ?? "—")
                    side: "bottom"
                }
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
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "↓" + (topbar.network?.downStr ?? "—")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          Tokens.color.green

                    Tooltip {
                        text: "Download: " + (topbar.network?.downStr ?? "—") + "/s\n" +
                              "Total reçu: " + (topbar.network?.totalRxStr ?? "—")
                        side: "bottom"
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           "↑" + (topbar.network?.upStr ?? "—")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          Tokens.color.netUp

                    Tooltip {
                        text: "Upload: " + (topbar.network?.upStr ?? "—") + "/s\n" +
                              "Total envoyé: " + (topbar.network?.totalTxStr ?? "—")
                        side: "bottom"
                    }
                }
            }

            Rectangle {
                width: 1; height: 12
                anchors.verticalCenter: parent.verticalCenter
                color: Tokens.color.borderNorm
            }

            Item {
                width: _volIcon.width + 4 + _volTxt.width
                height: parent.height

                Item {
                    id: _volIcon
                    width: 12; height: 12
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }

                    Icon {
                        anchors.centerIn: parent
                        icon:  (topbar.audio?.muted ?? false) ? "speaker" : "music"
                        size:  12
                        color: (topbar.audio?.muted ?? false) ? Tokens.color.fg5 : Tokens.color.fg3
                    }
                    Rectangle {
                        visible: topbar.audio?.muted ?? false
                        width: 14; height: 1.5
                        radius: 1
                        color: Tokens.color.red
                        anchors.centerIn: parent
                        rotation: -45
                    }
                }

                Text {
                    id: _volTxt
                    anchors { left: _volIcon.right; leftMargin: 4; verticalCenter: parent.verticalCenter }
                    width:          28
                    horizontalAlignment: Text.AlignRight
                    text:           (topbar.audio?.muted ?? false) ? "OFF" : ((topbar.audio?.volumePercent ?? 0) + "%")
                    font.family:    Tokens.font.sans
                    font.pixelSize: Tokens.font.xs
                    color:          (topbar.audio?.muted ?? false) ? Tokens.color.fg5 : Tokens.color.fg3
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: topbar.audio?.toggleMute()
                    onWheel: (w) => {
                        if (!topbar.audio) return
                        const step = 0.05
                        const nv = topbar.audio.volume + (w.angleDelta.y > 0 ? step : -step)
                        topbar.audio.setVolume(Math.max(0, Math.min(1, nv)))
                    }
                }

                Tooltip {
                    text: (topbar.audio?.sinkName ?? "Audio") + "\n" +
                          "Volume: " + (topbar.audio?.volumePercent ?? 0) + "%" +
                          ((topbar.audio?.muted ?? false) ? " (mute)" : "")
                    side: "bottom"
                }
            }
        }
    }
}
