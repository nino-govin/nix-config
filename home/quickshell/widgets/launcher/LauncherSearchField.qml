import QtQuick
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    property alias text: searchInput.text
    property alias focusTarget: searchInput
    property string placeholder: SettingsService.launcherCommandMode
        ? "Type / for command palette..." : "Search applications..."

    signal moveSelectionRequested(bool down)
    signal accepted
    signal closeRequested
    signal deleteRequested

    height: 46
    radius: ShellMetrics.radiusMedium
    color: Theme.panelSurfaceColor

    TextInput {
        id: searchInput

        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }

        verticalAlignment: TextInput.AlignVCenter
        color: Theme.primaryTextColor
        selectionColor: Theme.selectedSurfaceColor
        selectedTextColor: Theme.primaryTextColor
        font.pixelSize: 15
        font.family: Typography.bodyFontFamily
        clip: true

        Keys.onDownPressed: root.moveSelectionRequested(true)
        Keys.onUpPressed: root.moveSelectionRequested(false)
        Keys.onDeletePressed: event => {
            if (event.modifiers & Qt.ShiftModifier)
                root.deleteRequested();
            else
                event.accepted = false;
        }
        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
        Keys.onEscapePressed: {
            if (SettingsService.launcherEscapeClearsQuery && text.length > 0)
                text = "";
            else
                root.closeRequested();
        }
    }

    Text {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 14
        }
        visible: root.text.length === 0
        text: root.placeholder
        color: Theme.mutedTextColor
        font.pixelSize: 15
        font.family: Typography.bodyFontFamily
    }
}
