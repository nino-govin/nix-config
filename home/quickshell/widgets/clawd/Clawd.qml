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
        floor: floorY,
        grip: (spriteBody.y + spriteBody.height - gripRow) * pixelScale
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
    property string baseAnimation: "stand"
    readonly property string animation: gaze !== ""
        && ["stand", "idle_look"].indexOf(baseAnimation) !== -1
        ? "watch_" + gaze : baseAnimation

    readonly property int gripRow: 27
    readonly property var motions: ["walk", "climb", "reel", "float"]
    readonly property var aloft: ["climb", "reel", "float", "jump", "dangle", "letgo"]
    readonly property real shakeSpeed: 700
    readonly property real dizzyStep: 0.1
    readonly property real dizzyDecay: 0.2
    readonly property int stars: dizziness < 0.1 ? 0 : dizziness < 0.4 ? 1 : dizziness < 0.7 ? 2 : 3
    property real dizziness: 0
    property bool slid: false
    property var shakeSigns: ({ x: 0, y: 0 })
    property real splatUntil: 0
    property real lastApproach: 0

    property var rope: null
    property real ropeProgress: 1
    readonly property point hand: {
        const anchor = baseAnimation === "grapple" ? Qt.point(48, 16) : Qt.point(32, gripRow);
        return Qt.point(bodyX + (anchor.x - spriteBody.x + 0.5) * pixelScale,
            bodyY + (anchor.y - spriteBody.y) * pixelScale);
    }
    readonly property point ropeEnd: rope
        ? Qt.point(hand.x + (rope.x - hand.x) * ropeProgress,
            hand.y + (rope.y - hand.y) * ropeProgress)
        : hand

    readonly property point cursor: pointer.point.position
    readonly property string gaze: {
        if (!pointer.hovered || dragging)
            return "";
        const dx = cursor.x - (bodyX + bodyWidth / 2);
        const dy = cursor.y - (bodyY + bodyHeight * 0.3);
        const distance = Math.hypot(dx, dy);
        if (distance > 520 || distance < bodyWidth * 0.4)
            return "";
        const angle = Math.atan2(-dy, dx) * 180 / Math.PI;
        if (angle >= 67.5 && angle < 112.5)
            return "up";
        if (angle >= 22.5 && angle < 67.5)
            return "upright";
        if (angle >= 112.5 && angle < 157.5)
            return "upleft";
        if (Math.abs(angle) < 22.5)
            return "right";
        if (Math.abs(angle) >= 157.5)
            return "left";
        return "down";
    }

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
    signal landed(int platform)

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
            facing: -1,
            sliding: false,
            gliding: false,
            impact: 0
        };
        replan();
    }

    function sync(): void {
        bodyX = sim.x;
        bodyY = sim.y;
        facing = sim.facing;
        const now = Date.now();
        if (dragging)
            baseAnimation = stars > 0 ? "shaken_" + stars : "grabbed";
        else if (sim.airborne && sim.sliding)
            baseAnimation = now < splatUntil ? "splat"
                : sim.vy > 600 ? "slide_fast" : "slide";
        else if (sim.airborne && sim.gliding)
            baseAnimation = "parachute";
        else if (sim.airborne)
            baseAnimation = sim.vy < 0 ? "jump" : "fall";
        else if (!activity)
            baseAnimation = "stand";
        else
            baseAnimation = activity.animation || activity.kind;
    }

    function offSurface(): bool {
        return !sim.airborne && sim.platform < 0
            && sim.y + sim.height < world.floor - 1;
    }

    function fall(): void {
        activity = null;
        queue = [];
        rope = null;
        sim.airborne = true;
        sim.platform = -1;
        sim.vx = 0;
        sim.vy = 0;
        replanPending = true;
        moving = true;
        sync();
    }

    function start(next: var): void {
        activity = next;
        moving = false;
        activityTimer.stop();
        impactTimer.stop();
        if (!next || next.kind !== "reel")
            rope = null;
        if (!next) {
            if (offSurface())
                fall();
            else
                replan();
            return;
        }
        if (aloft.indexOf(next.kind) === -1 && offSurface()) {
            fall();
            return;
        }
        if (next.facing)
            sim.facing = next.facing;
        switch (next.kind) {
        case "rest":
            if (next.grapple !== undefined) {
                const target = platforms[next.grapple];
                if (!target || !target.active) {
                    advance();
                    return;
                }
                rope = {
                    x: sim.x + (32 - spriteBody.x + 0.5) * pixelScale,
                    y: next.underside ? target.y + target.height : target.y + 3 * pixelScale
                };
                throwAnimation.restart();
            }
            activityTimer.interval = next.duration;
            activityTimer.restart();
            break;
        case "climb":
        case "float":
            sim.platform = -1;
            moving = true;
            break;
        case "reel":
            if (!rope) {
                fall();
                return;
            }
            next.feet = rope.y + world.grip;
            sim.platform = -1;
            moving = true;
            break;
        case "dangle":
            activityTimer.interval = next.duration;
            activityTimer.restart();
            break;
        case "letgo":
            sim.airborne = true;
            sim.platform = -1;
            sim.gliding = next.glide;
            sim.vx = 0;
            sim.vy = 0;
            replanPending = true;
            moving = true;
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
        const motion = activity && !sim.airborne
            && motions.indexOf(activity.kind) !== -1 ? activity : undefined;
        const event = Brain.step(sim, platforms, world, dt, motion);
        if (event === "landed") {
            moving = false;
            if (sim.platform >= 0)
                root.landed(sim.platform);
            if (replanPending) {
                replanPending = false;
                queue = Brain.plan(context());
            }
            queue = Brain.recovery(sim, platforms, world, {
                crash: Brain.crashed(sim),
                dizzy: dizziness,
                slid: slid
            }).concat(queue);
            dizziness = 0;
            slid = false;
            advance();
        } else if (event === "arrived") {
            advance();
        } else if (event === "popped") {
            activity = null;
            queue = [];
            replanPending = true;
        } else if (event === "splat") {
            splatUntil = Date.now() + 520;
            slid = true;
            activity = null;
            queue = [];
            replanPending = true;
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
        shakeSigns = { x: 0, y: 0 };
        rope = null;
        sim.sliding = false;
        sim.gliding = false;
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

    function trackShake(velocity: vector2d): void {
        const signs = shakeSigns;
        for (const axis of ["x", "y"]) {
            const speed = velocity[axis];
            const sign = speed > shakeSpeed ? 1 : speed < -shakeSpeed ? -1 : 0;
            if (sign === 0 || sign === signs[axis])
                continue;
            if (signs[axis] !== 0)
                dizziness = Math.min(1, dizziness + dizzyStep);
            signs[axis] = sign;
        }
        shakeSigns = signs;
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
        rope = null;
        sim.sliding = false;
        sim.gliding = false;
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

    function perch(method: string): void {
        if (!sim || sim.airborne || dragging || offSurface())
            return;
        const trip = Brain.perchTrip(sim, platforms, world, method);
        if (!trip)
            return;
        queue = trip;
        advance();
    }

    function approachCursor(): void {
        const now = Date.now();
        if (!sim || !pointer.hovered || dragging || sim.airborne || offSurface()
            || ClawdService.state !== "idle" || !activity || activity.kind !== "rest"
            || queue.length > 0
            || now - lastApproach < 30000
            || Math.abs(cursor.x - (sim.x + sim.width / 2)) > 700
            || cursor.y > sim.y + sim.height || cursor.y < sim.y - 500)
            return;
        lastApproach = now;
        queue = Brain.approach(sim, platforms, world, cursor.x);
        advance();
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
        if (!sim.airborne && sim.platform < 0
            && !(activity && aloft.indexOf(activity.kind) !== -1))
            sim.y = world.floor - sim.height;
        sync();
    }

    function followPlatforms(): void {
        if (!sim || dragging || !shown)
            return;
        if (Brain.follow(sim, platforms))
            moving = true;
        sync();
    }

    onPlatformsChanged: Qt.callLater(followPlatforms)

    onShownChanged: {
        impactTimer.stop();
        if (!shown)
            activityTimer.stop();
        else if (activity && ["rest", "poke", "dangle"].indexOf(activity.kind) !== -1)
            activityTimer.restart();
    }

    Connections {
        target: ClawdService
        function onStateChanged(): void { root.requestReplan(); }
        function onToolChanged(): void { root.requestReplan(); }
        function onSummonRequested(): void { root.summon(); }
        function onPerformRequested(animation: string): void { root.perform(animation); }
        function onPerchRequested(method: string): void { root.perch(method); }
    }

    Timer {
        id: activityTimer
        onTriggered: root.advance()
    }

    Timer {
        interval: 100
        repeat: true
        running: root.dizziness > 0 && (root.dragging || root.moving)
        onTriggered: {
            root.dizziness = Math.max(0, root.dizziness - root.dizzyDecay * interval / 1000);
            if (root.dragging)
                root.sync();
        }
    }

    onCursorChanged: curiosityTimer.restart()

    Timer {
        id: curiosityTimer
        interval: 2500
        onTriggered: root.approachCursor()
    }

    SequentialAnimation {
        id: throwAnimation

        PropertyAction { target: root; property: "ropeProgress"; value: 0 }
        PauseAnimation { duration: 220 }
        NumberAnimation { target: root; property: "ropeProgress"; to: 1; duration: 320; easing.type: Easing.OutQuad }
    }

    HoverHandler {
        id: pointer
    }

    Item {
        id: ropeLine

        readonly property real dx: root.ropeEnd.x - root.hand.x
        readonly property real dy: root.ropeEnd.y - root.hand.y

        visible: root.rope !== null
        x: root.hand.x - width / 2
        y: root.hand.y
        width: 3 * root.pixelScale
        height: Math.hypot(dx, dy)
        transformOrigin: Item.Top
        rotation: Math.atan2(-dx, dy) * 180 / Math.PI

        Rectangle {
            anchors.fill: parent
            color: "#2B1A14"
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.pixelScale
            height: parent.height
            color: "#8E6B3F"
        }
    }

    ClawdSprite {
        visible: root.rope !== null
        x: root.ropeEnd.x - 32.5 * root.pixelScale
        y: root.ropeEnd.y - 32 * root.pixelScale
        width: implicitWidth
        height: implicitHeight
        pixelScale: root.pixelScale
        animation: "hook"
        running: false
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
                root.trackShake(centroid.velocity);
                root.dragTo(centroid.scenePosition);
            }
        }
    }
}
