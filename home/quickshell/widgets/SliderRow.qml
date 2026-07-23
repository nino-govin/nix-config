import QtQuick
import "../theme"

Row {
    id: root
    property string iconName: "sun"
    property color  barColor: Tokens.color.yellow
    property real   value:    0.6
    property real   minValue: 0.0

    signal moved(real value)

    onValueChanged: if (value < minValue) value = minValue

    spacing: 12
    height:  20

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        icon:  root.iconName
        size:  Tokens.size.iconXl
        color: root.barColor
    }

    Item {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width:  parent.width - 18 - 12 - 28 - 12
        height: 8

        HoverHandler { cursorShape: Qt.PointingHandCursor }

        Rectangle {
            anchors.fill: parent
            radius: Tokens.radius.sm
            color:  Tokens.color.trackBg
        }
        Rectangle {
            width:  track.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: Tokens.radius.sm
            color:  root.barColor
            Behavior on width { NumberAnimation { duration: 80 } }
        }
        Rectangle {
            x:      track.width * Math.max(0, Math.min(1, root.value)) - 8
            y:      (parent.height - 16) / 2
            width:  16; height: 16
            radius: 8
            color:  Tokens.color.fg0
            layer.enabled: true
        }

        Timer {
            id: _throttle
            interval: 100
            running:  false
            repeat:   true
            property real pendingValue: root.value
            onTriggered: root.moved(pendingValue)
        }

        DragHandler {
            target: null
            cursorShape: Qt.PointingHandCursor
            onActiveChanged: {
                if (active) {
                    _throttle.start()
                } else {
                    _throttle.stop()
                    const pct = Math.max(root.minValue, Math.min(1, centroid.position.x / track.width))
                    root.value = pct
                    root.moved(pct)
                }
            }
            onCentroidChanged: {
                if (!active) return
                const pct = Math.max(root.minValue, Math.min(1, centroid.position.x / track.width))
                root.value = pct
                _throttle.pendingValue = pct
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width:          28
        text:           Math.round(root.value * 100) + "%"
        font.family:    Tokens.font.sans
        font.pixelSize: Tokens.font.xs
        color:          Tokens.color.fg4
        horizontalAlignment: Text.AlignRight
    }
}
