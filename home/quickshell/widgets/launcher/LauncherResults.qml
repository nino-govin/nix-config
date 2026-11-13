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
    property string calculation: ""
    property string calculationExpression: ""

    readonly property bool calculatorMode: SettingsService.launcherCalculator
        && query.startsWith("=")

    readonly property bool commandMode: SettingsService.launcherCommandMode
        && query.startsWith("/")

    readonly property bool colorSchemeMode: commandMode
        && query.startsWith("/color ")

    readonly property bool clipboardMode: commandMode
        && query.startsWith("/clip ")

    values: {
        if (root.calculatorMode)
            return calculatorResults();

        if (root.colorSchemeMode)
            return colorSchemeResults();

        if (root.clipboardMode)
            return clipboardResults();

        if (root.commandMode) {
            const search = root.query.slice(1).trim().toLowerCase();

            return root.commands.filter(command => search.length === 0 || command.name.toLowerCase().includes(search));
        }

        const search = root.query.trim().toLowerCase();

        return [...DesktopEntries.applications.values].map(application => {
            const frecency = LauncherUsageService.frecency(application.id);
            if (search.length === 0)
                return { application: application, score: frecency };
            const nameScore = LauncherUsageService.matchScore(search, application.name);
            const extraScore = [application.genericName, application.comment, ...application.keywords]
                .some(text => text && text.toLowerCase().includes(search)) ? 40 : -1;
            const match = Math.max(nameScore, extraScore);
            return { application: application, score: match < 0 ? -1 : match + Math.min(30, frecency * 3) };
        }).filter(entry => entry.score >= 0).sort((first, second) => {
            return second.score - first.score
                || first.application.name.localeCompare(second.application.name)
                || first.application.id.localeCompare(second.application.id);
        }).map(entry => ({
                    key: "app:" + entry.application.id,
                    type: "application",
                    application: entry.application,
                    name: entry.application.name,
                    detail: entry.application.genericName || entry.application.comment || "Application"
                }));
    }

    function calculatorResults(): var {
        if (root.calculation === "")
            return [];

        return [
            {
                key: "calc",
                type: "calculator",
                name: root.calculation,
                detail: root.calculationExpression,
                icon: Icons.calculator,
                value: root.calculation
            }
        ];
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
