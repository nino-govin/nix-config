import Quickshell.Io
import QtQuick

Item {
    id: root

    property var entries: []

    function refresh(): void {
        if (!lister.running)
            lister.running = true;
    }

    function remove(line: string): void {
        entries = entries.filter(entry => entry.line !== line);
        remover.command = ["sh", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "sh", line];
        remover.running = true;
    }

    function copy(entryId: string): void {
        copier.command = ["sh", "-c", "cliphist decode \"$1\" | wl-copy", "sh", entryId];
        copier.running = true;
    }

    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(line => line.length > 0).map(line => {
                    const separator = line.indexOf("\t");
                    return {
                        line: line,
                        id: line.slice(0, separator),
                        preview: line.slice(separator + 1)
                    };
                });
            }
        }
    }

    Process {
        id: copier
    }

    Process {
        id: remover
        onExited: root.refresh()
    }
}
