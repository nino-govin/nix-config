import QtQuick
import Quickshell.Io

Item {
    id: root

    property string animation: "stand"
    property bool running: true
    property int facing: 1
    property int pixelScale: 4

    property var frames: []
    property var tags: ({})
    property rect body: Qt.rect(14, 37, 36, 23)
    property int step: 0
    property int revision: 0
    property string current: "stand"
    property bool once: false
    property var pending: []

    readonly property var mirrorable: ["stand", "walk", "jump", "fall", "land", "grabbed", "poke", "poke_down", "poke_up",
        "stagger", "teeter", "climb", "splat", "slide", "slide_fast"]
    readonly property bool mirrored: facing < 0 && mirrorable.indexOf(current) !== -1
    readonly property string target: tags[animation] ? animation : "stand"
    readonly property bool settled: current === target && !once
    readonly property var tag: tags[current] || tags.stand || null
    readonly property int length: tag ? tag.to - tag.from + 1 : 1
    readonly property int frameIndex: tag
        ? tag.from + (once ? Math.min(step, length - 1) : step % length) : 0
    readonly property var frame: frames.length > frameIndex ? frames[frameIndex] : null
    readonly property int frameSize: frame ? frame.frame.w : 64

    signal frameEntered(string tag, int frame)

    implicitWidth: frameSize * pixelScale
    implicitHeight: frameSize * pixelScale

    function load(text: string): void {
        try {
            const data = JSON.parse(text);
            const parsed = {};
            for (const entry of data.meta.frameTags)
                parsed[entry.name] = entry;
            const slice = (data.meta.slices || []).find(entry => entry.name === "body");
            if (slice) {
                const bounds = slice.keys[0].bounds;
                body = Qt.rect(bounds.x, bounds.y, bounds.w, bounds.h);
            }
            frames = data.frames;
            tags = parsed;
            revision++;
            if (!tags[current]) {
                current = target;
                once = false;
            }
        } catch (error) {
            console.warn("Could not load Clawd sprite data:", error);
        }
    }

    function transition(): void {
        const base = current.replace(/_(in|out)$/, "");
        if (base === target && !current.endsWith("_out")) {
            pending = once ? [{ name: target, once: false }] : [];
            return;
        }
        const queue = [];
        if (!current.endsWith("_out") && tags[base + "_out"])
            queue.push({ name: base + "_out", once: true });
        if (tags[target + "_in"])
            queue.push({ name: target + "_in", once: true });
        queue.push({ name: target, once: false });
        pending = queue;
        if (!once || current.endsWith("_in"))
            advance();
    }

    function advance(): void {
        const next = pending.length > 0 ? pending.shift() : { name: target, once: false };
        pending = pending;
        step = 0;
        once = next.once;
        current = next.name;
    }

    onTargetChanged: transition()
    onFrameIndexChanged: {
        if (running && tag)
            frameEntered(current, frameIndex - tag.from);
    }

    FileView {
        path: Qt.resolvedUrl("assets/clawd.json").toString().replace(/^file:\/\//, "")
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.load(text())
    }

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("assets/clawd.png") + "?" + root.revision
        sourceClipRect: root.frame
            ? Qt.rect(root.frame.frame.x, root.frame.frame.y,
                root.frame.frame.w, root.frame.frame.h)
            : Qt.rect(0, 0, 0, 0)
        smooth: false
        mipmap: false
        cache: false
        mirror: root.mirrored
    }

    Timer {
        interval: root.frame ? root.frame.duration : 1000
        running: root.running && root.tag !== null
            && (root.once || root.length > 1)
        repeat: true
        onTriggered: {
            if (root.once && root.step >= root.length - 1)
                root.advance();
            else
                root.step++;
        }
    }
}
