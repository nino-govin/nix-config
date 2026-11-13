pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string stateHome: Quickshell.env("XDG_STATE_HOME")
        || Quickshell.env("HOME") + "/.local/state"

    property var usage: ({})

    function record(id: string): void {
        const next = Object.assign({}, usage);
        const entry = next[id] || { count: 0, last: 0 };
        next[id] = { count: entry.count + 1, last: Date.now() };
        usage = next;
        usageFile.setText(JSON.stringify(next));
    }

    function frecency(id: string): real {
        const entry = usage[id];
        if (!entry)
            return 0;
        const hours = (Date.now() - entry.last) / 3600000;
        const weight = hours < 4 ? 4 : hours < 24 ? 2 : hours < 168 ? 1 : 0.5;
        return entry.count * weight;
    }

    function matchScore(query: string, text: string): real {
        const target = (text || "").toLowerCase();
        if (target.startsWith(query))
            return 100;
        const index = target.indexOf(query);
        if (index >= 0)
            return /[\s\-_.]/.test(target[index - 1]) ? 85 : 70;
        let from = 0;
        let previous = -2;
        let points = 0;
        for (const character of query) {
            const found = target.indexOf(character, from);
            if (found < 0)
                return -1;
            points += found === 0 || /[\s\-_.]/.test(target[found - 1]) ? 6 : found === previous + 1 ? 4 : 1;
            previous = found;
            from = found + 1;
        }
        return 10 + points / query.length * 8;
    }

    FileView {
        id: usageFile
        path: root.stateHome + "/quickshell-launcher-usage.json"
        printErrors: false
        onLoaded: {
            try {
                root.usage = JSON.parse(text());
            } catch (error) {
                root.usage = {};
            }
        }
    }
}
