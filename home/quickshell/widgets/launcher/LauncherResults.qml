import Quickshell
import QtQuick
import "../../components/theme"
import "../../services"

ScriptModel {
    id: root

    objectProp: "key"

    property string query: ""
    property var commands: []
    property var clipboardEntries: []

    readonly property bool commandMode: SettingsService.launcherCommandMode
        && query.startsWith("/")

    readonly property bool colorSchemeMode: commandMode
        && query.startsWith("/color ")

    readonly property bool clipboardMode: commandMode
        && query.startsWith("/clip ")

    values: {
        if (root.colorSchemeMode)
            return colorSchemeResults();

        if (root.clipboardMode)
            return clipboardResults();

        if (root.commandMode) {
            const search = root.query.slice(1).trim().toLowerCase();

            return root.commands.filter(command => search.length === 0 || command.name.toLowerCase().includes(search));
        }

        const search = root.query.trim().toLowerCase();

        const applications = [...DesktopEntries.applications.values];

        const matches = search.length === 0 ? applications : applications.filter(application => {
            const searchable = [application.name, application.genericName, application.comment, ...application.keywords].join(" ").toLowerCase();

            return searchable.includes(search);
        });

        return matches.sort((first, second) => {
            const nameComparison = first.name.localeCompare(second.name);

            return nameComparison !== 0 ? nameComparison : first.id.localeCompare(second.id);
        }).map(application => ({
                    key: "app:" + application.id,
                    type: "application",
                    application: application,
                    name: application.name,
                    detail: application.genericName || application.comment || "Application"
                }));
    }

    function clipboardResults(): var {
        const search = root.query.slice("/clip ".length).trim().toLowerCase();

        return root.clipboardEntries.filter(entry => search.length === 0 || entry.preview.toLowerCase().includes(search)).map(entry => {
            const image = entry.preview.startsWith("[[ binary data");
            return {
                key: "clip:" + entry.id,
                type: "clipboard",
                name: image ? "Image" : entry.preview.trim(),
                detail: image ? entry.preview.replace(/^\[\[ binary data |\]\]$/g, "") : "",
                icon: image ? Icons.clipboardImage : Icons.clipboard,
                entryId: entry.id,
                line: entry.line
            };
        });
    }

    function colorSchemeResults(): var {
        const search = root.query.slice("/color ".length).trim().toLowerCase();

        return Theme.availableThemes.filter(theme => search.length === 0 || theme.name.toLowerCase().includes(search)).map(theme => ({
                    key: "theme:" + theme.id,
                    type: "colorScheme",
                    name: theme.name,
                    detail: theme.id === "dynamic" ? "Wallpaper-derived palette" : "Built-in palette",
                    themeId: theme.id
                }));
    }
}
