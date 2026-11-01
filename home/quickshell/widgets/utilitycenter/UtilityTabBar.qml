import QtQuick
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    required property string currentPage

    signal pageRequested(string page)

    readonly property var pages: [
        { page: "notifications", icon: Icons.notifications, label: "Notifications" },
        { page: "wifi", icon: Icons.wifi, label: "Wi-Fi" },
        { page: "bluetooth", icon: Icons.bluetooth, label: "Bluetooth" }
    ]
    readonly property real padding: 3
    readonly property real innerWidth: width - padding * 2
    readonly property real activeWidth: innerWidth * 0.5
    readonly property real inactiveWidth: (innerWidth - activeWidth) / (pages.length - 1)

    radius: height / 2
    color: Theme.panelSurfaceColor

    Row {
        anchors.fill: parent
        anchors.margins: root.padding

        Repeater {
            model: root.pages

            Rectangle {
                id: tab

                required property var modelData
                readonly property bool active: root.currentPage === modelData.page

                width: active ? root.activeWidth : root.inactiveWidth
                height: parent.height
                radius: height / 2
                color: active ? Theme.accentColor : "transparent"

                Behavior on width {
                    MotionAnimation { type: MotionAnimation.FastSpatial }
                }

                Behavior on color {
                    MotionColorAnimation { type: MotionAnimation.FastEffects }
                }

                StateLayer {
                    anchors.fill: parent
                    radius: parent.radius
                    hovered: tabHover.hovered && !tab.active
                    pressed: tabTap.pressed
                    stateColor: Theme.surfaceTextColor
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: tab.modelData.icon
                        color: tab.active ? Theme.accentTextColor : Theme.mutedTextColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 16
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: tab.active
                        text: tab.modelData.label
                        color: Theme.accentTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: Typography.labelLarge
                        font.weight: Font.Medium
                    }
                }

                HoverHandler {
                    id: tabHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: tabTap
                    onTapped: root.pageRequested(tab.modelData.page)
                }
            }
        }
    }
}
