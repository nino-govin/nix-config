import QtQuick
import QtQuick.Effects
import "../theme"

Rectangle {
    id: root
    property var media: null

    implicitHeight: _col.implicitHeight + 32
    radius: Tokens.radius.xl3
    clip: true

    color: Tokens.color.itemBg
    border.color: Tokens.color.borderFaint
    border.width: 1

    Image {
        id: _artBg
        anchors.fill: parent
        source: root.media?.artUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        cache: true
        opacity: source !== "" && status === Image.Ready ? 0.35 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.13, 0.15, 0.18, 0.55) }
            GradientStop { position: 1.0; color: Qt.rgba(0.13, 0.15, 0.18, 0.85) }
        }
    }

    Column {
        id: _col
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
        spacing: 12

        Rectangle {
            id: _artFrame
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120; height: 120
            radius: Tokens.radius.xl2
            color: Tokens.color.bg3
            clip: true

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled:        true
                shadowColor:          "#AA000000"
                shadowVerticalOffset: 4
                shadowBlur:           1.6
            }

            Image {
                anchors.fill: parent
                source: root.media?.artUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: true
                visible: source !== "" && status === Image.Ready
            }

            Icon {
                visible: (root.media?.artUrl ?? "") === "" || _artBg.status !== Image.Ready
                anchors.centerIn: parent
                icon: "note"
                size: 48
                color: Tokens.color.fg4
                strokeWidth: 1.6
            }
        }

        Column {
            width: parent.width
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.media?.title !== "" ? root.media.title : "Aucun média"
                font.family: Tokens.font.sans
                font.pixelSize: Tokens.font.md
                font.weight: Font.DemiBold
                color: Tokens.color.fg0
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (root.media?.artist ?? "") !== ""
                    ? root.media.artist + ((root.media?.album ?? "") !== "" ? " · " + root.media.album : "")
                    : "—"
                font.family: Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color: Tokens.color.fg4
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item {
            width: parent.width
            height: 5
            visible: (root.media?.length ?? 0) > 0

            Rectangle {
                anchors.fill: parent
                radius: 2.5
                color: Tokens.color.trackBg
            }
            Rectangle {
                height: parent.height
                radius: 2.5
                color: Tokens.color.blue
                width: parent.width * Math.max(0, Math.min(1,
                    (root.media?.length ?? 0) > 0
                        ? (root.media.position / root.media.length)
                        : 0))
                Behavior on width { NumberAnimation { duration: 300 } }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 22
            topPadding: 2

            Item {
                width: 22; height: 22
                anchors.verticalCenter: _playBtn.verticalCenter

                Icon {
                    anchors.centerIn: parent
                    icon:  "skipPrev"
                    size:  22
                    color: (root.media?.canPrev ?? false) ? Tokens.color.fg2 : Tokens.color.fg5
                    strokeWidth: 1.7
                    opacity: (root.media?.canPrev ?? false) ? 1 : 0.4
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: root.media?.canPrev ?? false
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.media?.previous()
                }
            }

            Rectangle {
                id: _playBtn
                width: 40; height: 40
                radius: 20
                color: Tokens.color.fg0

                Icon {
                    anchors.centerIn: parent
                    icon:  (root.media?.isPlaying ?? false) ? "pause" : "play"
                    size:  18
                    color: Tokens.color.bg0
                    strokeWidth: 2.0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.media?.togglePlay()
                }
            }

            Item {
                width: 22; height: 22
                anchors.verticalCenter: _playBtn.verticalCenter

                Icon {
                    anchors.centerIn: parent
                    icon:  "skipNext"
                    size:  22
                    color: (root.media?.canNext ?? false) ? Tokens.color.fg2 : Tokens.color.fg5
                    strokeWidth: 1.7
                    opacity: (root.media?.canNext ?? false) ? 1 : 0.4
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: root.media?.canNext ?? false
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.media?.next()
                }
            }
        }
    }
}
