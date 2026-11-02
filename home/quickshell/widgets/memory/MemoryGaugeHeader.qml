import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Column {
    id: root

    readonly property color usageColor: MemoryService.usage < 0.5
        ? Theme.successColor
        : MemoryService.usage < 0.8 ? Theme.accentColor : Theme.dangerColor
    readonly property color cacheColor: Theme.withOpacity(usageColor, 0.45)

    component LegendItem: Row {
        property color swatchColor
        property real swatchWidth: 10
        property string label

        spacing: 6

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.swatchWidth
            height: 10
            radius: Math.min(3, width / 2)
            color: parent.swatchColor
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.label
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: Typography.labelSmall
        }
    }

    spacing: 10

    ArcGauge {
        id: gauge

        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: 260
        thickness: 16
        segments: [
            { value: MemoryService.usage, color: root.usageColor },
            { value: MemoryService.reclaimableUsage, color: root.cacheColor }
        ]
        markers: [
            { value: 0.5, color: Theme.mutedTextColor, width: 1.5 },
            { value: 0.8, color: Theme.mutedTextColor, width: 1.5 },
            { value: MemoryService.peakUsage, color: Theme.primaryTextColor, width: 3 }
        ]

        Column {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            spacing: 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: MemoryService.format(MemoryService.usedKiB)
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.headlineSmall
                font.weight: Font.Medium
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "of " + MemoryService.format(MemoryService.totalKiB)
                    + " · " + Math.round(MemoryService.usage * 100) + "%"
                color: Theme.secondaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.bodySmall
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: MemoryService.format(MemoryService.availableKiB) + " available"
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: Typography.labelSmall
            }
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        LegendItem {
            swatchColor: root.usageColor
            label: "Used"
        }

        LegendItem {
            swatchColor: root.cacheColor
            label: "Cache"
        }

        LegendItem {
            swatchColor: Theme.primaryTextColor
            swatchWidth: 3
            label: "Peak " + MemoryService.format(MemoryService.peakKiB)
        }
    }
}
