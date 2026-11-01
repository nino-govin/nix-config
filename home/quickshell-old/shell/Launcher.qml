import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "../widgets"

PanelWindow {
    id: root

    property bool open: false
    signal panelClosed

    WlrLayershell.namespace:     "quickshell-launcher"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { left: true; right: true; top: true; bottom: true }
    color: "transparent"
    visible: open

    onOpenChanged: {
        if (open) {
            _query = ""
            _selected = 0
            _searchField.text = ""
            _searchField.forceActiveFocus()
        }
    }

    property string _query: ""
    property int    _selected: 0

    property var _all: {
        const list = []
        const apps = DesktopEntries.applications.values
        for (let i = 0; i < apps.length; i++) {
            const a = apps[i]
            if (a.noDisplay) continue
            list.push(a)
        }
        list.sort((a, b) => a.name.localeCompare(b.name))
        return list
    }

    function _score(app, q) {
        if (q === "") return 1
        const lq = q.toLowerCase()
        const name = (app.name || "").toLowerCase()
        const gen = (app.genericName || "").toLowerCase()
        const kw = ((app.keywords || []).join(" ") + " " + (app.categories || []).join(" ")).toLowerCase()
        if (name.startsWith(lq)) return 100
        if (name.includes(lq))   return 80
        if (gen.includes(lq))    return 60
        if (kw.includes(lq))     return 40
        let fi = 0
        for (let i = 0; i < name.length && fi < lq.length; i++) {
            if (name[i] === lq[fi]) fi++
        }
        return fi === lq.length ? 20 : 0
    }

    property var _filtered: {
        void _query; void _all
        const q = _query.trim()
        const scored = []
        for (let i = 0; i < _all.length; i++) {
            const s = _score(_all[i], q)
            if (s > 0) scored.push({ app: _all[i], score: s })
        }
        scored.sort((a, b) => b.score - a.score)
        return scored.slice(0, 40).map(x => x.app)
    }

    function _launch(app) {
        if (!app) return
        app.execute()
        root.panelClosed()
    }

    Rectangle {
        anchors.fill: parent
        color: "#99000000"
        MouseArea { anchors.fill: parent; onClicked: root.panelClosed() }
    }

    Column {
        anchors.centerIn: parent
        width: 640
        spacing: 16

        Rectangle {
            id: _search
            width: parent.width
            height: 60
            radius: Tokens.radius.xl3
            color: Tokens.color.modalBg
            border.color: Tokens.color.borderNorm
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled:        true
                shadowColor:          "#CC000000"
                shadowVerticalOffset: 6
                shadowBlur:           2.0
            }

            MouseArea { anchors.fill: parent }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 22
                spacing: 14

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "browser"
                    size: 20
                    color: Tokens.color.fg3
                    strokeWidth: 1.8
                }

                TextField {
                    id: _searchField
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 34
                    background: Item {}
                    placeholderText: "Rechercher une application…"
                    color: Tokens.color.fg0
                    placeholderTextColor: Tokens.color.fg5
                    font.family: Tokens.font.sans
                    font.pixelSize: Tokens.font.lg
                    selectByMouse: true
                    padding: 0
                    onTextChanged: {
                        root._query = text
                        root._selected = 0
                    }
                    Keys.onEscapePressed: root.panelClosed()
                    Keys.onReturnPressed: root._launch(root._filtered[root._selected])
                    Keys.onEnterPressed:  root._launch(root._filtered[root._selected])
                    Keys.onDownPressed: {
                        if (root._selected < root._filtered.length - 1) root._selected++
                    }
                    Keys.onUpPressed: {
                        if (root._selected > 0) root._selected--
                    }
                }
            }
        }

        Rectangle {
            id: _resultsWrap
            visible: root._filtered.length > 0
            width: parent.width
            height: Math.min(440, root._filtered.length * 56 + 12)
            radius: Tokens.radius.xl3
            color: Tokens.color.modalBg
            border.color: Tokens.color.borderNorm
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled:        true
                shadowColor:          "#CC000000"
                shadowVerticalOffset: 6
                shadowBlur:           2.0
            }

            MouseArea { anchors.fill: parent }

            ListView {
                id: _list
                anchors.fill: parent
                anchors.margins: 6
                clip: true
                model: root._filtered
                currentIndex: root._selected
                boundsBehavior: Flickable.StopAtBounds
                spacing: 2
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    width:  _list.width
                    height: 54
                    radius: Tokens.radius.lg
                    color:  index === root._selected ? Tokens.color.itemBg : "transparent"
                    Behavior on color { ColorAnimation { duration: 80 } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32; height: 32
                            source: modelData.icon ? Quickshell.iconPath(modelData.icon, "application-x-executable") : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            asynchronous: true
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 46
                            spacing: 1

                            Text {
                                text: modelData.name ?? ""
                                font.family: Tokens.font.sans
                                font.pixelSize: Tokens.font.md
                                font.weight: index === root._selected ? Font.DemiBold : Font.Medium
                                color: Tokens.color.fg0
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            Text {
                                visible: (modelData.genericName ?? "") !== "" || (modelData.comment ?? "") !== ""
                                text: (modelData.genericName ?? "") !== "" ? modelData.genericName : (modelData.comment ?? "")
                                font.family: Tokens.font.sans
                                font.pixelSize: Tokens.font.xs
                                color: Tokens.color.fg4
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: root._selected = index
                        onClicked: root._launch(modelData)
                    }
                }
            }
        }

        Rectangle {
            visible: root._filtered.length === 0 && root._query !== ""
            width: parent.width
            height: 60
            radius: Tokens.radius.xl3
            color: Tokens.color.modalBg
            border.color: Tokens.color.borderNorm
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Aucun résultat pour « " + root._query + " »"
                font.family: Tokens.font.sans
                font.pixelSize: Tokens.font.sm
                color: Tokens.color.fg4
            }
        }
    }
}
