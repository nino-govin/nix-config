import Quickshell.Io
import QtQuick

Item {
    id: root

    property string expression: ""
    property string result: ""
    property string resultExpression: ""

    function copy(value: string): void {
        copier.command = ["wl-copy", "--", value];
        copier.running = true;
    }

    onExpressionChanged: {
        if (expression.trim().length === 0) {
            debounce.stop();
            result = "";
            return;
        }
        debounce.restart();
    }

    Timer {
        id: debounce
        interval: 120
        onTriggered: {
            if (evaluator.running)
                return;
            evaluator.pending = root.expression.trim();
            evaluator.command = ["qalc", "-t", " " + evaluator.pending];
            evaluator.running = true;
        }
    }

    Process {
        id: evaluator

        property string pending: ""

        stdout: StdioCollector {
            id: output
        }

        onExited: code => {
            if (evaluator.pending !== root.expression.trim()) {
                if (root.expression.trim().length > 0)
                    debounce.restart();
                return;
            }
            const value = output.text.trim();
            root.result = code === 0 ? value : "";
            root.resultExpression = evaluator.pending;
        }
    }

    Process {
        id: copier
    }
}
