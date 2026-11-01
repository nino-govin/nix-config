import QtQuick
import Quickshell
import "../theme"

Item {
    id: root
    property string text: ""
    property string side: "right"
    property int delay: 350
    property int maxWidth: 340
    property int offset: 8

    anchors.fill: parent
    z: 9999

    property bool _show: false

    HoverHandler {
        id: _hh
        onHoveredChanged: {
            if (hovered && root.text !== "") _t.restart()
            else { _t.stop(); root._show = false }
        }
    }

    Timer {
        id: _t
        interval: root.delay
        repeat: false
        onTriggered: if (_hh.hovered) root._show = true
    }

    PopupWindow {
        id: _pop
        color: "transparent"
        visible: root._show && anchor.item !== null

        implicitWidth:  _bg.implicitWidth
        implicitHeight: _bg.implicitHeight

        anchor {
            item: root
            rect.x: root.side === "right"  ? root.width + root.offset
                  : root.side === "left"   ? -_pop.implicitWidth - root.offset
                                           : Math.round((root.width - _pop.implicitWidth) / 2)
            rect.y: root.side === "right"  ? Math.round((root.height - _pop.implicitHeight) / 2)
                  : root.side === "left"   ? Math.round((root.height - _pop.implicitHeight) / 2)
                  : root.side === "top"    ? -_pop.implicitHeight - root.offset
                                           : root.height + root.offset
            rect.width: _pop.implicitWidth
            rect.height: _pop.implicitHeight
        }

        Rectangle {
            id: _bg
            implicitWidth:  Math.min(_lbl.implicitWidth + 16, root.maxWidth)
            implicitHeight: _lbl.implicitHeight + 10
            radius: Tokens.radius.md
            color:  Tokens.color.modalBg
            border.color: Tokens.color.borderNorm
            border.width: 1

            Text {
                id: _lbl
                anchors.centerIn: parent
                text: root.text
                font.family: Tokens.font.sans
                font.pixelSize: Tokens.font.xs
                color: Tokens.color.fg0
                wrapMode: Text.WordWrap
                width: Math.min(implicitWidth, root.maxWidth - 16)
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
