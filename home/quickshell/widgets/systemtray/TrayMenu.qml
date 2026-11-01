import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import "../../components/common"
import "../../components/theme"

PopupWindow {
    id: root

    property var menuStack: []
    readonly property var currentMenu: menuStack.length > 0
        ? menuStack[menuStack.length - 1] : null

    function toggle(handle, item: Item): void {
        if (visible && anchor.item === item) {
            close();
            return;
        }
        open(handle, item);
    }

    function open(handle, item: Item): void {
        anchor.item = item;
        anchor.rect.x = item.width / 2 - implicitWidth / 2;
        anchor.rect.y = item.height + 10;
        menuStack = [handle];
        visible = true;
    }

    function close(): void {
        visible = false;
        menuStack = [];
    }

    function push(handle): void {
        menuStack = menuStack.concat([handle]);
    }

    function pop(): void {
        menuStack = menuStack.slice(0, -1);
    }

    implicitWidth: 240
    implicitHeight: content.implicitHeight + 12
    color: "transparent"

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        onCleared: root.close()
    }

    onVisibleChanged: {
        if (visible)
            grabTimer.restart();
        else
            focusGrab.active = false;
    }

    Timer {
        id: grabTimer
        interval: 50
        onTriggered: focusGrab.active = root.visible
    }

    HoverDismissController {
        active: root.visible
        panelHovered: menuHover.hovered
        externalHovered: false
        onDismissRequested: root.close()
    }

    QsMenuOpener {
        id: opener
        menu: root.currentMenu
    }

    Rectangle {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        radius: ShellMetrics.radiusLarge

        HoverHandler {
            id: menuHover
        }

        color: Theme.surfaceContainerColor
        border.width: 1
        border.color: Theme.outlineVariantColor

        Column {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 6
            }

            MenuRow {
                visible: root.menuStack.length > 1
                text: "Back"
                iconText: Icons.previousMonth
                onActivated: root.pop()
            }

            Repeater {
                model: opener.children

                Loader {
                    required property QsMenuEntry modelData

                    width: content.width
                    sourceComponent: modelData.isSeparator ? separator : entry

                    Component {
                        id: separator

                        Item {
                            height: 9

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 16
                                height: 1
                                color: Theme.outlineVariantColor
                            }
                        }
                    }

                    Component {
                        id: entry

                        MenuRow {
                            text: modelData.text
                            iconSource: modelData.icon
                            enabled: modelData.enabled
                            checked: modelData.buttonType !== QsMenuButtonType.None
                                && modelData.checkState === Qt.Checked
                            hasChildren: modelData.hasChildren
                            onActivated: {
                                if (modelData.hasChildren) {
                                    root.push(modelData);
                                } else {
                                    modelData.triggered();
                                    root.close();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component MenuRow: Item {
        id: row

        property string text: ""
        property string iconSource: ""
        property string iconText: ""
        property bool checked: false
        property bool hasChildren: false
        signal activated()

        width: parent ? parent.width : 0
        height: 34
        opacity: enabled ? 1 : 0.45

        StateLayer {
            anchors.fill: parent
            radius: ShellMetrics.radiusMedium
            hovered: rowHover.hovered
            pressed: rowTap.pressed
        }

        Row {
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            Item {
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    anchors.fill: parent
                    visible: row.iconSource !== ""
                    source: row.iconSource
                }

                Text {
                    anchors.centerIn: parent
                    visible: row.iconSource === ""
                    text: row.checked ? Icons.confirm : row.iconText
                    color: Theme.accentColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                }
            }

            Text {
                width: parent.width - 52
                anchors.verticalCenter: parent.verticalCenter
                text: row.text.replace(/_(?!_)/g, "")
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.bodyMedium
                elide: Text.ElideRight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: row.hasChildren
                text: Icons.nextMonth
                color: Theme.mutedTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 14
            }
        }

        HoverHandler {
            id: rowHover
            enabled: row.enabled
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: rowTap
            enabled: row.enabled
            onTapped: row.activated()
        }
    }
}
