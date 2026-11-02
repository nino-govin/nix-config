import QtQuick
import "../../components/theme"
import "../../services"
import "../launcher"

Item {
    id: root

    property bool shown: false
    property real maximumHeight: 620
    property real bottomPadding: ShellMetrics.panelContentInsetFromEdge
    property alias focusTarget: searchField.focusTarget

    readonly property real headerHeight: 30
    readonly property real rowHeight: 32
    readonly property real columnSpacing: 28
    readonly property real fixedContentHeight: 18 + 12 + 46 + bottomPadding
    readonly property int columnCount: Math.max(1, Math.floor((width - 40 + columnSpacing) / (300 + columnSpacing)))
    readonly property real columnWidth: (width - 40 - columnSpacing * (columnCount - 1)) / columnCount
    readonly property string query: searchField.text.trim().toLowerCase()

    readonly property var filtered: KeybindService.categories.map(category => {
        if (query === "" || category.name.toLowerCase().includes(query))
            return category;
        return {
            name: category.name,
            binds: category.binds.filter(bind => bind.label.toLowerCase().includes(query)
                || bind.keys.join(" ").toLowerCase().includes(query))
        };
    }).filter(category => category.binds.length > 0)

    readonly property var columns: {
        const result = [];
        const heights = [];
        for (let i = 0; i < columnCount; i++) {
            result.push([]);
            heights.push(0);
        }
        for (const category of filtered) {
            const target = heights.indexOf(Math.min(...heights));
            result[target].push(category);
            heights[target] += headerHeight + category.binds.length * rowHeight + 16;
        }
        return result;
    }

    readonly property real desiredHeight: Math.min(maximumHeight,
        fixedContentHeight + Math.max(rowHeight * 2, columnsRow.implicitHeight))

    signal closeRequested

    Flickable {
        id: flickable

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: searchField.top
            topMargin: 18
            leftMargin: 20
            rightMargin: 20
            bottomMargin: 12
        }
        contentHeight: columnsRow.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Row {
            id: columnsRow
            spacing: root.columnSpacing

            Repeater {
                model: root.columns

                Column {
                    required property var modelData
                    width: root.columnWidth
                    spacing: 16

                    Repeater {
                        model: parent.modelData

                        Column {
                            required property var modelData
                            width: root.columnWidth

                            Text {
                                height: root.headerHeight
                                text: parent.modelData.name
                                verticalAlignment: Text.AlignVCenter
                                color: Theme.accentColor
                                font.family: Typography.bodyFontFamily
                                font.pixelSize: Typography.titleSmall
                                font.weight: Font.Medium
                            }

                            Repeater {
                                model: parent.modelData.binds

                                KeybindRow {
                                    required property var modelData
                                    width: root.columnWidth
                                    height: root.rowHeight
                                    keys: modelData.keys
                                    label: modelData.label
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: flickable
        visible: root.filtered.length === 0
        text: KeybindService.categories.length === 0
            ? "No described keybinds" : "No shortcuts found"
        color: Theme.mutedTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: Typography.bodyMedium
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
        placeholder: "Search shortcuts..."

        onCloseRequested: root.closeRequested()
    }

    onShownChanged: {
        if (shown)
            searchField.text = "";
    }
}
