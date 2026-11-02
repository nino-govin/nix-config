import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""
    property string detail: ""
    property bool highlighted: false

    implicitHeight: 62
    radius: ShellMetrics.radiusLarge
    color: Theme.panelSurfaceColor

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: ShellMetrics.radiusMedium
            color: root.highlighted ? Theme.accentColor : Theme.selectedSurfaceColor

            Behavior on color {
                MotionColorAnimation { type: MotionAnimation.FastEffects }
            }

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.highlighted ? Theme.accentTextColor : Theme.accentColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 17

                Behavior on color {
                    MotionColorAnimation { type: MotionAnimation.FastEffects }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.label
                elide: Text.ElideRight
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.labelSmall
            }

            Text {
                Layout.fillWidth: true
                text: root.value
                elide: Text.ElideRight
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.bodyMedium
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                visible: root.detail !== ""
                text: root.detail
                elide: Text.ElideRight
                color: Theme.secondaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.labelSmall
            }
        }
    }
}
