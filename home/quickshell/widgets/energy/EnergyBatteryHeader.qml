import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/theme"
import "../../services"

RowLayout {
    id: root

    readonly property string statusText: {
        const parts = [];
        if (BatteryService.charging)
            parts.push("Charging");
        else if (BatteryService.discharging)
            parts.push("Discharging");
        else if (BatteryService.acOnline)
            parts.push(BatteryService.status === "Full" ? "Plugged in · full" : "Plugged in · not charging");
        else
            parts.push(BatteryService.status);
        if (BatteryService.watts > 0.05)
            parts.push(BatteryService.watts.toFixed(1) + " W");
        const remaining = BatteryService.formatDuration(BatteryService.minutesRemaining);
        if (remaining !== "")
            parts.push(BatteryService.charging ? "full in " + remaining : remaining + " left");
        return parts.join(" · ");
    }
    readonly property color ringColor: BatteryService.charging
        ? Theme.successColor
        : BatteryService.percent > 20 ? Theme.accentColor : Theme.dangerColor

    spacing: 16

    Item {
        Layout.preferredWidth: 60
        Layout.preferredHeight: 60

        StatusRing {
            anchors.fill: parent
            value: BatteryService.level
            ringColor: root.ringColor
            ringWidth: 5
        }

        Text {
            anchors.centerIn: parent
            text: BatteryService.icon
            color: root.ringColor
            font.family: Typography.materialIconFontFamily
            font.pixelSize: 22

            Behavior on color {
                MotionColorAnimation { type: MotionAnimation.FastEffects }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        Text {
            text: BatteryService.percent + "%"
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.headlineSmall
            font.weight: Font.Medium
        }

        Text {
            Layout.fillWidth: true
            text: root.statusText
            elide: Text.ElideRight
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.bodySmall
        }
    }
}
