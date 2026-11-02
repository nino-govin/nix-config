import QtQuick
import "../../components/theme"

Rectangle {
    id: root

    required property string key
    readonly property bool superKey: key === "SUPER"

    implicitWidth: Math.max(implicitHeight, label.implicitWidth + 14)
    implicitHeight: 24
    radius: ShellMetrics.radiusSmall
    color: Theme.selectedSurfaceColor
    border.width: 1
    border.color: Theme.outlineVariantColor

    Text {
        id: label
        anchors.centerIn: parent
        text: root.superKey ? Icons.nixos : root.key
        color: root.superKey ? Theme.accentColor : Theme.primaryTextColor
        font.family: root.superKey ? Typography.nerdIconFontFamily : Typography.bodyFontFamily
        font.pixelSize: root.superKey ? 14 : Typography.labelMedium
        font.weight: Font.Medium
    }
}
