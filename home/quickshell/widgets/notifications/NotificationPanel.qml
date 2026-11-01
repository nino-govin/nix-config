import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Text {
                text: "Notifications"
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 15
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }

            Text {
                visible: NotificationService.notificationCount > 0
                text: "Clear all"
                color: clearHover.hovered
                    ? Theme.dangerColor
                    : Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 11

                HoverHandler {
                    id: clearHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler { onTapped: NotificationService.clear() }
            }

            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.leftMargin: 6
                radius: ShellMetrics.radiusMedium
                color: SettingsService.doNotDisturb ? Theme.accentColor : "transparent"

                Behavior on color {
                    MotionColorAnimation { type: MotionAnimation.FastEffects }
                }

                StateLayer {
                    anchors.fill: parent
                    radius: parent.radius
                    hovered: dndHover.hovered
                    pressed: dndTap.pressed
                    stateColor: SettingsService.doNotDisturb
                        ? Theme.accentTextColor : Theme.surfaceTextColor
                }

                Text {
                    anchors.centerIn: parent
                    text: SettingsService.doNotDisturb ? Icons.notificationsOff : Icons.notifications
                    color: SettingsService.doNotDisturb ? Theme.accentTextColor : Theme.mutedTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 16
                }

                HoverHandler {
                    id: dndHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: dndTap
                    onTapped: NotificationService.toggleDoNotDisturb()
                }
            }
        }

        ListView {
            id: list

            Layout.fillWidth: true
            Layout.fillHeight: true
            model: NotificationService.notificationModel
            spacing: 10
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            remove: Transition {
                MotionAnimation {
                    group: "notification"
                    type: MotionAnimation.FastEffects
                    property: "opacity"
                    to: 0
                }
            }

            removeDisplaced: Transition {
                MotionAnimation {
                    group: "notification"
                    property: "y"
                }
            }

            delegate: Item {
                id: delegateRoot

                required property var notification
                required property int notificationId
                required property string appName
                required property string summary
                required property string body
                required property string icon
                required property var receivedAt

                width: list.width
                height: card.implicitHeight

                Connections {
                    target: delegateRoot.notification
                    function onClosed(reason) {
                        NotificationService.removeById(delegateRoot.notificationId);
                    }
                }

                NotificationCard {
                    id: card
                    anchors.fill: parent
                    notificationId: delegateRoot.notificationId
                    appName: delegateRoot.appName
                    summary: delegateRoot.summary
                    body: delegateRoot.body
                    iconSource: delegateRoot.icon
                    receivedAt: delegateRoot.receivedAt
                    notification: delegateRoot.notification
                    popup: false
                    onCloseRequested: notificationId =>
                        NotificationService.dismissById(notificationId)
                    onActionRequested: (notificationId, actionIdentifier) =>
                        NotificationService.invokeAction(notificationId, actionIdentifier)
                }
            }

            Text {
                anchors.centerIn: parent
                visible: NotificationService.notificationCount === 0
                text: "No notifications"
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 13
            }
        }
    }
}
