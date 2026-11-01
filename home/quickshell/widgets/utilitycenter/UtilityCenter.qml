import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../connectivity"
import "../notifications"
import "../../services"

Item {
    id: root

    readonly property int pageIndex: OverlayState.utilityPage === "wifi" ? 1
        : OverlayState.utilityPage === "bluetooth" ? 2 : 0
    focus: OverlayState.utilityCenterVisible
    Keys.onEscapePressed: OverlayState.hideUtilityCenter()

    ColumnLayout {
        anchors {
            fill: parent
            topMargin: 28
            rightMargin: ShellMetrics.panelContentInsetFromEdge
            bottomMargin: 16
            leftMargin: 16
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            Layout.maximumHeight: 38
            spacing: 10

            QuickActionButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                Layout.preferredWidth: 1
                icon: Icons.caffeine
                label: "Keep awake"
                active: IdleInhibitService.inhibited
                onClicked: IdleInhibitService.toggle()
            }

            QuickActionButton {
                readonly property var icons: ({
                    economy: Icons.powerEconomy,
                    balanced: Icons.powerBalanced,
                    performance: Icons.powerPerformance
                })
                readonly property var labels: ({
                    economy: "Economy",
                    balanced: "Balanced",
                    performance: "Performance"
                })
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                Layout.preferredWidth: 1
                icon: icons[PowerProfileService.mode]
                label: labels[PowerProfileService.mode]
                active: PowerProfileService.mode !== "balanced"
                onClicked: PowerProfileService.cycle()
            }
        }

        UtilityTabBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            currentPage: OverlayState.utilityPage
            onPageRequested: page => OverlayState.utilityPage = page
        }


        Item {
            id: pageViewport

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            NotificationPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (0 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    MotionAnimation {}
                }
            }

            WifiPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (1 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    MotionAnimation {}
                }
            }

            BluetoothPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (2 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    MotionAnimation {}
                }
            }
        }

        CalendarPanel {
            Layout.fillWidth: true
            Layout.preferredHeight: 260
        }
    }

    HoverHandler {
        id: widgetHover
    }

    HoverDismissController {
        active: OverlayState.utilityCenterVisible
        panelHovered: widgetHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hideUtilityCenter()
    }
}
