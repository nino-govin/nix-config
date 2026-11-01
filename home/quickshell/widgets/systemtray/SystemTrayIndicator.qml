import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    visible: SystemTray.items.values.length > 0
    width: visible ? icons.width + 20 : 0
    height: 26
    radius: height / 2
    color: Theme.panelSurfaceColor

    TrayMenu {
        id: menu
    }

    Row {
        id: icons

        anchors.centerIn: parent
        height: parent.height
        spacing: 8

        Repeater {
            model: SystemTray.items

            Item {
                id: trayItem

                required property SystemTrayItem modelData

                width: 18
                height: parent.height

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 16
                    source: trayItem.modelData.icon
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        const item = trayItem.modelData;
                        if (mouse.button === Qt.MiddleButton)
                            item.secondaryActivate();
                        else if (item.hasMenu && (mouse.button === Qt.RightButton || item.onlyMenu))
                            menu.toggle(item.menu, trayItem);
                        else
                            item.activate();
                    }
                    onWheel: wheel => trayItem.modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }
}
