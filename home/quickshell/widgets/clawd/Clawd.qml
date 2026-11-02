import QtQuick
import Quickshell
import "../../services"
import "ClawdBrain.js" as Brain

Item {
    id: root

    property real ceilingY: 0
    property real floorY: height
    property var platforms: []
    property bool shown: false

    readonly property int pixelScale: SettingsService.clawdScale
    readonly property rect spriteBody: sprite.body
    readonly property real bodyWidth: spriteBody.width * pixelScale
    readonly property real bodyHeight: spriteBody.height * pixelScale
    readonly property var world: ({
        left: 0,
        right: width,
        top: ceilingY,
        floor: floorY
    })

    property var sim: null
    property var queue: []
    property var activity: null
    property bool moving: false
    property bool dragging: false
    property bool replanPending: false
    property point grabOffset: Qt.point(0, 0)
    property vector2d dragVelocity: Qt.vector2d(0, 0)

    property real bodyX: 0
    property real bodyY: 0
    property int facing: 1
    property string animation: "stand"

    readonly property bool night: clock.hours >= 22 || clock.hours < 6
    readonly property var reactions: {
        const list = [];
        if ((CpuService.temperatureAvailable && CpuService.temperature >= 80)
            || CpuService.usage >= 0.85)
            list.push("fan");
        if (BatteryService.available && BatteryService.charging
            && BatteryService.percent < 95)
            list.push("charge");
        if (BatteryService.available && BatteryService.discharging
            && BatteryService.percent <= 20)
            list.push("yawn");
        const code = WeatherService.available ? WeatherService.weatherCode : -1;
        if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99].includes(code))
            list.push("umbrella");
        else if ([71, 73, 75, 77, 85, 86].includes(code))
            list.push("snow");
        else if ((code === 0 || code === 1) && clock.hours >= 9 && clock.hours < 19)
            list.push("sunglasses");
        if (NetworkTrafficService.downloadRate + NetworkTrafficService.uploadRate >= 2097152)
            list.push("packets");
        if (MemoryService.usage >= 0.85)
            list.push("juggle");
        return list;
    }

    signal poked(int platform, string direction)

    visible: shown

    function context(): var {
        return {
            sim: sim,
            platforms: platforms,
            world: world,
            state: ClawdService.state,
            tool: ClawdService.tool,
            reactions: reactions,
            night: night,
            media: MediaService.playing,
            activity: SettingsService.clawdActivity
        };
    }

    function ensureSim(): void {
        if (sim || width <= 0 || height <= 0)
            return;
        sim = {
            x: world.right - bodyWidth - 96,
            y: world.floor - bodyHeight,
            width: bodyWidth,
            height: bodyHeight,
            vx: 0,
            vy: 0,
            airborne: false,
            platform: -1,
            platformX: 0,
            facing: -1
        };
        replan();
    }

    function sync(): void {
        bodyX = sim.x;
        bodyY = sim.y;
        facing = sim.facing;
        if (dragging)
            animation = "grabbed";
        else if (sim.airborne)
            animation = sim.vy < 0 ? "jump" : "fall";
        else if (!activity)
            animation = "stand";
        else
            animation = activity.animation || activity.kind;
    }

    function start(next: var): void {
        activity = next;
        moving = false;
        activityTimer.stop();
        impactTimer.stop();
        if (!next) {
            replan();
            return;
        }
        switch (next.kind) {
        case "rest":
            activityTimer.interval = next.duration;
            activityTimer.restart();
            break;
        case "walk":
            next.targetX = Brain.clampX(world, sim, next.targetX);
            moving = true;
            break;
        case "jump": {
            const platform = platforms[next.platform];
            if (!platform || !platform.active) {
                advance();
                return;
            }
            Brain.launch(sim, next.targetX, platform.y);
            moving = true;
            break;
        }
        case "poke":
            if (next.facing)
                sim.facing = next.facing;
            activityTimer.interval = 900;
            activityTimer.restart();
            impactTimer.interval = next.impact;
            impactTimer.restart();
            break;
        }
        sync();
    }

    function advance(): void {
        start(queue.length > 0 ? queue.shift() : null);
    }

    function replan(): void {
        replanPending = false;
        queue = Brain.plan(context());
        advance();
    }

    function tick(dt: real): void {
        if (!sim.airborne && !sprite.settled) {
            sync();
            return;
        }
        const walkTarget = activity && activity.kind === "walk" && !sim.airborne
            ? activity.targetX : undefined;
        const event = Brain.step(sim, platforms, world, dt, walkTarget);
        if (event === "landed") {
            moving = false;
            if (replanPending) {
                replanPending = false;
                queue = Brain.plan(context());
            }
            queue.unshift({ kind: "rest", animation: "land", duration: 180 });
            advance();
        } else if (event === "arrived") {
            advance();
        }
        sync();
    }

    function requestReplan(): void {
        if (!sim)
            return;
        if (sim.airborne || dragging)
            replanPending = true;
        else
            replan();
    }

    function grab(position: point): void {
        dragging = true;
        dragVelocity = Qt.vector2d(0, 0);
        moving = false;
        activityTimer.stop();
        impactTimer.stop();
        activity = null;
        queue = [];
        sim.airborne = false;
        sim.platform = -1;
        grabOffset = Qt.point(position.x - sim.x, position.y - sim.y);
        sync();
    }

    function dragTo(position: point): void {
        sim.x = Brain.clampX(world, sim, position.x - grabOffset.x);
        sim.y = Math.max(world.top, Math.min(world.floor - sim.height,
            position.y - grabOffset.y));
        sync();
    }

    function release(velocity: vector2d): void {
        dragging = false;
        Brain.release(sim, velocity.x, velocity.y);
        replanPending = true;
        moving = true;
        sync();
    }

    function summon(): void {
        if (!sim)
            return;
        activityTimer.stop();
        impactTimer.stop();
        activity = null;
        queue = [];
        sim.x = (width - sim.width) / 2;
        sim.y = world.top;
        sim.vx = 0;
        sim.vy = 0;
        sim.airborne = true;
        sim.platform = -1;
        replanPending = true;
        moving = true;
        sync();
    }

    function perform(animation: string): void {
        if (!sim || sim.airborne || dragging)
            return;
        queue = [];
        start({ kind: "rest", animation: animation, duration: 8000 });
    }

    onSpriteBodyChanged: resize()
    onPixelScaleChanged: resize()

    function resize(): void {
        if (!sim)
            return;
        const feet = sim.y + sim.height;
        const width = spriteBody.width * pixelScale;
        sim.x += (sim.width - width) / 2;
        sim.width = width;
        sim.height = spriteBody.height * pixelScale;
        sim.x = Brain.clampX(world, sim, sim.x);
        sim.y = feet - sim.height;
        sync();
    }

    onWidthChanged: ensureSim()
    onHeightChanged: ensureSim()

    onWorldChanged: {
        if (!sim || dragging)
            return;
        sim.x = Brain.clampX(world, sim, sim.x);
        if (!sim.airborne && sim.platform < 0)
            sim.y = world.floor - sim.height;
        sync();
    }

    onPlatformsChanged: {
        if (!sim || dragging)
            return;
        if (Brain.follow(sim, platforms))
            moving = true;
        sync();
    }

    onShownChanged: {
        impactTimer.stop();
        if (!shown)
            activityTimer.stop();
        else if (activity && (activity.kind === "rest" || activity.kind === "poke"))
            activityTimer.restart();
    }

    Connections {
        target: ClawdService
        function onStateChanged(): void { root.requestReplan(); }
        function onToolChanged(): void { root.requestReplan(); }
        function onSummonRequested(): void { root.summon(); }
        function onPerformRequested(animation: string): void { root.perform(animation); }
    }

    Timer {
        id: activityTimer
        onTriggered: root.advance()
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Timer {
        id: impactTimer
        onTriggered: {
            if (root.activity && root.activity.kind === "poke")
                root.poked(root.activity.platform, root.activity.direction);
        }
    }

    FrameAnimation {
        running: root.shown && root.moving && !root.dragging
        onTriggered: root.tick(Math.min(frameTime, 0.05))
    }

    Item {
        id: hitbox

        x: root.bodyX
        y: root.bodyY
        width: root.bodyWidth
        height: root.bodyHeight

        ClawdSprite {
            id: sprite

            x: -(mirrored
                ? implicitWidth / root.pixelScale - sprite.body.x - sprite.body.width
                : sprite.body.x) * root.pixelScale
            y: -sprite.body.y * root.pixelScale
            width: implicitWidth
            height: implicitHeight
            pixelScale: root.pixelScale
            animation: root.animation
            facing: root.facing
            running: root.shown
        }

        TapHandler {
            onTapped: ClawdService.activate()
        }

        DragHandler {
            target: null
            onActiveChanged: {
                if (active)
                    root.grab(centroid.scenePosition);
                else
                    root.release(root.dragVelocity);
            }
            onCentroidChanged: {
                if (!active)
                    return;
                root.dragVelocity = centroid.velocity;
                root.dragTo(centroid.scenePosition);
            }
        }
    }
}
