import Quickshell
import QtQuick
import "../../components/theme"
import "../../components/state"
import "../../services"

Item {
    id: root

    property bool shown: false
    property string initialQuery: ""
    property int requestSerial: 0

    property real maximumHeight: 620
    property real resultRowHeight: 60
    property real bottomPadding: ShellMetrics.panelContentInsetFromEdge

    readonly property real fixedContentHeight: 12 + 8 + 46 + bottomPadding

    readonly property int maximumVisibleRows: Math.max(1, Math.min(
        SettingsService.launcherVisibleRows,
        Math.floor((maximumHeight - fixedContentHeight) / resultRowHeight)))

    readonly property int visibleResultRows: Math.max(1, Math.min(launcherResults.values.length, maximumVisibleRows))

    readonly property real desiredHeight: Math.min(maximumHeight, fixedContentHeight + visibleResultRows * resultRowHeight)

    readonly property bool commandMode: launcherResults.commandMode

    property alias focusTarget: searchField.focusTarget

    signal closeRequested

    LauncherCommands {
        id: launcherCommands
    }

    ClipboardHistory {
        id: clipboard
    }

    LauncherResults {
        id: launcherResults

        clipboardEntries: clipboard.entries

        query: searchField.text

        commands: launcherCommands.items
    }

    function launchResult(result): void {
        switch (result.type) {
        case "application":
            launchApplication(result);
            break;
        case "command":
            runCommand(result.command);
            break;
        case "clipboard":
            clipboard.copy(result.entryId);
            root.closeRequested();
            break;
        case "colorScheme":
            Theme.setTheme(result.themeId);
            if (SettingsService.launcherCloseOnLaunch)
                root.closeRequested();
            break;
        }
    }

    function launchApplication(result): void {
        result.application.execute();
        if (SettingsService.launcherCloseOnLaunch)
            root.closeRequested();
    }

    function runCommand(command: string): void {
        switch (command) {
        case "settings":
            OverlayState.showSettings();
            break;
        case "colorScheme":
            searchField.text = "/color ";
            break;
        case "clipboard":
            searchField.text = "/clip ";
            break;
        case "wallpapers":
            OverlayState.showWallpaperPicker();
            break;
        }
    }

    LauncherSearchField {
        id: searchField

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            bottomMargin: root.bottomPadding

            leftMargin: 14
            rightMargin: 14
        }

        onMoveSelectionRequested: down => resultList.moveSelection(down)

        onDeleteRequested: resultList.deleteCurrent()

        onAccepted: resultList.activateCurrent()

        onCloseRequested: root.closeRequested()

        onTextChanged: resultList.resetSelection()
    }

    LauncherResultList {
        id: resultList

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: searchField.top

            topMargin: 12
            leftMargin: 14
            rightMargin: 14
            bottomMargin: 8
        }

        model: launcherResults

        rowHeight: root.resultRowHeight

        emptyText: root.commandMode ? "No commands found" : "No applications found"

        onActivated: result => root.launchResult(result)

        onDeleteRequested: result => {
            if (result.type === "clipboard")
                clipboard.remove(result.line);
        }
    }

    onShownChanged: {
        if (!shown)
            return;

        if (!SettingsService.launcherRememberQuery || root.initialQuery !== "")
            searchField.text = root.initialQuery;

        if (launcherResults.clipboardMode)
            clipboard.refresh();

        resultList.resetSelection();
    }

    onRequestSerialChanged: {
        if (!shown)
            return;

        if (!SettingsService.launcherRememberQuery || root.initialQuery !== "")
            searchField.text = root.initialQuery;

        resultList.resetSelection();
    }

    Connections {
        target: launcherResults

        function onClipboardModeChanged(): void {
            if (launcherResults.clipboardMode)
                clipboard.refresh();
        }
    }
}
