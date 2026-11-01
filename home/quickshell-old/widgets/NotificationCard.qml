import QtQuick
import "../theme"

Rectangle {
    id: root
    property string variant:     "neutral"
    property string iconName:    "check"
    property string title:       ""
    property string body:        ""
    property string timeStr:     ""
    property bool   compact:     false
    property bool   showActions: false
    property string action1:     "Ignorer"
    property string action2:     "Action"

    signal action1Triggered
    signal action2Triggered
    signal dismissed

    readonly property var _palette: ({
        success:  { icon: Tokens.color.blue,   bg: Tokens.color.cardBg,  border: Tokens.color.borderNorm },
        neutral:  { icon: Tokens.color.bg3,    bg: Tokens.color.cardBg,  border: Tokens.color.borderNorm },
        warning:  { icon: Tokens.color.red,    bg: "rgba(191,97,106,0.22)", border: "rgba(191,97,106,0.35)" },
        download: { icon: Tokens.color.green,  bg: Tokens.color.cardBg,  border: Tokens.color.borderNorm }
    })
    readonly property var _pal: _palette[variant] ?? _palette.neutral

    implicitWidth:  parent?.width ?? 320
    implicitHeight: compact ? 40 : (showActions ? 120 : (body !== "" ? 80 : 56))
    radius:   compact ? Tokens.radius.xl : Tokens.radius.xl3
    color:    _pal.bg
    border.color: _pal.border
    border.width: 1

    Row {
        anchors {
            left: parent.left; right: parent.right
            verticalCenter: compact ? parent.verticalCenter : undefined
            top: compact ? undefined : parent.top
            topMargin: compact ? 0 : 14
            leftMargin:  compact ? 10 : 14
            rightMargin: compact ? 10 : 14
        }
        spacing: compact ? 10 : 12

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width:  compact ? 22 : 34
            height: compact ? 22 : 34
            radius: compact ? Tokens.radius.lg : Tokens.radius.xl
            color:  root._pal.icon

            Icon {
                anchors.centerIn: parent
                icon:  root.iconName
                size:  compact ? 11 : 14
                color: Tokens.color.bg0
                strokeWidth: 2.4
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            width: parent.parent.width - (compact ? 22 : 34) - (compact ? 10 : 12)
                   - (compact ? 20 : 28)

            Row {
                width: parent.width
                Text {
                    text:           root.title
                    font.family:    Tokens.font.sans
                    font.pixelSize: compact ? Tokens.font.md : 12
                    font.weight:    Font.DemiBold
                    color:          Tokens.color.fg0
                    elide:          Text.ElideRight
                    width:          parent.width - timeLabel.width - 8
                }
                Text {
                    id: timeLabel
                    text:           root.timeStr
                    font.family:    Tokens.font.sans
                    font.pixelSize: 9
                    color:          Tokens.color.fg4
                    anchors.baseline: parent.children[0].baseline
                }
            }
            Text {
                visible:        !compact && root.body !== ""
                text:           root.body
                font.family:    Tokens.font.sans
                font.pixelSize: 11
                color:          "#c3cadb"
                wrapMode:       Text.WordWrap
                width:          parent.width
            }
        }
    }

    Row {
        visible:     !compact && root.showActions
        anchors {
            bottom: parent.bottom; bottomMargin: 14
            left:   parent.left;  leftMargin:   14
        }
        spacing: 8

        Rectangle {
            width: 80; height: 30; radius: Tokens.radius.lg
            color: Tokens.color.itemBg
            Text {
                anchors.centerIn: parent
                text:           root.action1
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.sm
                color:          Tokens.color.fg2
            }
            TapHandler { onTapped: root.action1Triggered() }
        }
        Rectangle {
            width: 120; height: 30; radius: Tokens.radius.lg
            color: root._pal.icon
            Text {
                anchors.centerIn: parent
                text:           root.action2
                font.family:    Tokens.font.sans
                font.pixelSize: Tokens.font.sm
                font.weight:    Font.DemiBold
                color:          Tokens.color.bg0
            }
            TapHandler { onTapped: root.action2Triggered() }
        }
    }

    TapHandler { onLongPressed: root.dismissed() }
}
