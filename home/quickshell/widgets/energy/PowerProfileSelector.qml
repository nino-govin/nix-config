import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    readonly property int refreshMin: PowerProfileService.refreshMin
    readonly property int refreshMax: PowerProfileService.refreshMax
    readonly property var profiles: [
        {
            mode: "economy",
            label: "Economy",
            icon: Icons.powerEconomy,
            details: [refreshMin > 0 ? refreshMin + " Hz" : "Lowest refresh", "Turbo off, 800 MHz", "Effects off"]
        },
        {
            mode: "balanced",
            label: "Balanced",
            icon: Icons.powerBalanced,
            details: [refreshMax > 0 ? refreshMin + "–" + refreshMax + " Hz auto" : "Adaptive refresh",
                "auto-cpufreq", "Effects on"]
        },
        {
            mode: "performance",
            label: "Performance",
            icon: Icons.powerPerformance,
            details: [refreshMax > 0 ? refreshMax + " Hz" : "Highest refresh", "Turbo on", "Wi-Fi saving off"]
        }
    ]
    readonly property real spacing: 10
    readonly property real cardWidth: (width - spacing * (profiles.length - 1)) / profiles.length
    readonly property int activeIndex: Math.max(0,
        profiles.findIndex(profile => profile.mode === PowerProfileService.mode))

    implicitHeight: 138

    Repeater {
        model: root.profiles

        Rectangle {
            required property int index
            x: index * (root.cardWidth + root.spacing)
            width: root.cardWidth
            height: root.height
            radius: ShellMetrics.radiusExtraLarge
            color: Theme.panelSurfaceColor
        }
    }

    Rectangle {
        property real position: root.activeIndex

        x: position * (root.cardWidth + root.spacing)
        width: root.cardWidth
        height: root.height
        radius: ShellMetrics.radiusExtraLarge
        color: Theme.accentColor

        Behavior on position {
            MotionAnimation { type: MotionAnimation.FastSpatial }
        }
    }

    Repeater {
        model: root.profiles

        Item {
            id: card

            required property var modelData
            required property int index
            readonly property bool active: index === root.activeIndex
            readonly property bool pending: PowerProfileService.applying
                && PowerProfileService.pendingMode === modelData.mode

            x: index * (root.cardWidth + root.spacing)
            width: root.cardWidth
            height: root.height

            StateLayer {
                anchors.fill: parent
                radius: ShellMetrics.radiusExtraLarge
                hovered: cardHover.hovered && !PowerProfileService.applying
                pressed: cardTap.pressed
                stateColor: card.active ? Theme.accentTextColor : Theme.surfaceTextColor
            }

            Column {
                id: cardContent

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 14
                }
                spacing: 2

                SequentialAnimation on opacity {
                    running: card.pending
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    NumberAnimation { to: 0.45; duration: 420; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1; duration: 420; easing.type: Easing.InOutQuad }
                }

                Text {
                    text: card.modelData.icon
                    color: card.active ? Theme.accentTextColor : Theme.accentColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 22
                    bottomPadding: 6

                    Behavior on color {
                        MotionColorAnimation { type: MotionAnimation.FastEffects }
                    }
                }

                Text {
                    width: parent.width
                    text: card.modelData.label
                    elide: Text.ElideRight
                    color: card.active ? Theme.accentTextColor : Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: Typography.titleSmall
                    font.weight: Font.Medium
                    bottomPadding: 4

                    Behavior on color {
                        MotionColorAnimation { type: MotionAnimation.FastEffects }
                    }
                }

                Repeater {
                    model: card.modelData.details

                    Text {
                        required property string modelData
                        width: cardContent.width
                        text: modelData
                        elide: Text.ElideRight
                        color: card.active ? Theme.accentTextColor : Theme.mutedTextColor
                        opacity: card.active ? 0.85 : 1
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: Typography.labelSmall

                        Behavior on color {
                            MotionColorAnimation { type: MotionAnimation.FastEffects }
                        }
                    }
                }
            }

            HoverHandler {
                id: cardHover
                cursorShape: PowerProfileService.applying ? Qt.BusyCursor : Qt.PointingHandCursor
            }

            TapHandler {
                id: cardTap
                onTapped: {
                    if (!card.active)
                        PowerProfileService.setMode(card.modelData.mode);
                }
            }
        }
    }
}
