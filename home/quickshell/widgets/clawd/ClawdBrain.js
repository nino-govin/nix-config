.pragma library

const gravity = 2400;
const walkSpeed = 140;
const apexClearance = 70;
const maxThrowSpeed = 1800;
const edgeMargin = 0.3;
const pokeReach = [0.35, 0.9];
const jumpReach = 2.5;
const jumpRise = 7.5;
const bounceReach = [0.3, 2.5];
const arcPerDistance = 0.35;
const routeDepth = 4;
const climbSpeed = 110;
const reelSpeed = 240;
const floatSpeed = 120;
const floatLift = 150;
const burstChance = 0.25;
const slideGrip = 0.52;
const slideAccel = 900;
const slideSpeed = 1300;
const splatSpeed = 1100;
const crashSpeed = 1900;
const staggerSpeed = 55;
const glideSpeed = 160;
const glideDrift = 60;
const crashHeight = crashSpeed * crashSpeed / (2 * gravity);

function random(min, max) {
    return min + Math.random() * (max - min);
}

function pick(options) {
    const total = options.reduce((sum, option) => sum + option[1], 0);
    let roll = Math.random() * total;
    for (const option of options) {
        roll -= option[1];
        if (roll <= 0)
            return option[0];
    }
    return options[options.length - 1][0];
}

function restAnimation(state, tool, night) {
    switch (state) {
    case "sleeping":
        return night ? "nightcap" : "sleep";
    case "working":
        return tool !== "" && tool !== "think" ? "work_" + tool : "think";
    case "thinking":
        return "think";
    case "attention":
        return "attention";
    case "ready":
        return "ready";
    }
    return "stand";
}

function restDuration(state) {
    switch (state) {
    case "sleeping":
        return random(45000, 90000);
    case "attention":
        return 4000;
    }
    return random(6000, 14000);
}

const idles = [
    { animation: "idle_look", weight: 3, duration: [3000, 6000] },
    { animation: "idle_read", weight: 1, duration: [7000, 12000] },
    { animation: "idle_coffee", weight: 2, duration: [6000, 10000] },
    { animation: "idle_music", weight: 2, duration: [6000, 11000] },
    { animation: "idle_bubbles", weight: 2, duration: [5000, 8000] },
    { animation: "idle_mania", weight: 2, duration: [6000, 11000] }
];

function idleRest(media, activity) {
    const idle = pick(idles.map(entry => [entry,
        entry.animation === "idle_music" && media ? entry.weight * 3 : entry.weight]));
    return {
        kind: "rest",
        animation: idle.animation,
        duration: random(idle.duration[0], idle.duration[1]) / activity
    };
}

function center(sim) {
    return sim.x + sim.width / 2;
}

function overlaps(a, b) {
    return a.x < b.x + b.width && b.x < a.x + a.width
        && a.y < b.y + b.height && b.y < a.y + a.height;
}

function landable(platforms, sim, world) {
    const active = platforms.filter(platform => platform.active);
    return active.filter(platform => {
        const room = {
            x: platform.x,
            y: platform.y - sim.height,
            width: platform.width,
            height: sim.height
        };
        return platform.width >= sim.width * 0.6
            && platform.y - sim.height >= world.top
            && !active.some(other => other.id !== platform.id
                && overlaps(room, other));
    });
}

function supports(platform, x) {
    return x >= platform.x && x <= platform.x + platform.width;
}

function clampX(world, sim, x) {
    return Math.max(world.left, Math.min(world.right - sim.width, x));
}

function surface(id, sim, platforms, world) {
    const platform = id >= 0 ? platforms[id] : null;
    if (!platform)
        return { id: -1, y: world.floor, left: world.left, right: world.right - sim.width };
    return {
        id: id,
        y: platform.y,
        left: Math.max(world.left, platform.x - sim.width * edgeMargin),
        right: Math.min(world.right - sim.width,
            platform.x + platform.width - sim.width * (1 - edgeMargin))
    };
}

function surfaceRange(sim, platforms, world) {
    return surface(sim.platform, sim, platforms, world);
}

function landingRange(platform, sim, world) {
    return {
        left: clampX(world, sim, platform.x),
        right: clampX(world, sim, Math.max(platform.x, platform.x + platform.width - sim.width))
    };
}

function hopWindow(from, platform, sim, world) {
    if (from.id === platform.id || from.y - platform.y > sim.height * jumpRise
        || platform.y - from.y > crashHeight * 0.75)
        return null;
    const range = landingRange(platform, sim, world);
    const reach = sim.width * jumpReach;
    const left = Math.max(range.left, from.left - reach);
    const right = Math.min(range.right, from.right + reach);
    return left <= right ? { left: left, right: right } : null;
}

function hop(from, platform, sim, world, x) {
    const window = hopWindow(from, platform, sim, world);
    if (!window)
        return null;
    const reach = sim.width * jumpReach;
    const targetX = random(window.left, window.right);
    const launchX = Math.max(from.left, Math.min(from.right,
        Math.max(targetX - reach, Math.min(targetX + reach, x))));
    const jump = { kind: "jump", platform: platform.id, targetX: targetX };
    return {
        x: targetX,
        steps: Math.abs(launchX - x) > 1
            ? [{ kind: "walk", targetX: launchX }, jump] : [jump]
    };
}

function wanderTarget(sim, platforms, world) {
    const range = surfaceRange(sim, platforms, world);
    return random(range.left, Math.max(range.left, range.right));
}

function jumpOptions(sim, platforms, world) {
    const from = surfaceRange(sim, platforms, world);
    return landable(platforms, sim, world)
        .map(platform => hop(from, platform, sim, world, sim.x))
        .filter(option => option)
        .map(option => option.steps);
}

function bounces(sim, platforms, world) {
    const range = surfaceRange(sim, platforms, world);
    const count = Math.floor(random(1, 4));
    const direction = Math.random() < 0.5 ? -1 : 1;
    const steps = [];
    let x = sim.x;
    for (let index = 0; index < count; index++) {
        const distance = sim.width * random(bounceReach[0], bounceReach[1]);
        let targetX = x + direction * distance;
        if (targetX < range.left || targetX > range.right)
            targetX = x - direction * distance;
        if (targetX < range.left || targetX > range.right)
            break;
        steps.push({ kind: "jump", platform: sim.platform, targetX: targetX });
        x = targetX;
    }
    return steps;
}

function route(sim, platforms, world, goal) {
    const nodes = landable(platforms, sim, world);
    const paths = [[sim.platform]];
    const seen = {};
    seen[sim.platform] = true;
    while (paths.length > 0) {
        const path = paths.shift();
        if (path.length > routeDepth)
            continue;
        const from = surface(path[path.length - 1], sim, platforms, world);
        for (const platform of nodes) {
            if (seen[platform.id] || !hopWindow(from, platform, sim, world))
                continue;
            const next = path.concat([platform.id]);
            if (platform.id === goal.id)
                return hops(next, sim, platforms, world);
            seen[platform.id] = true;
            paths.push(next);
        }
    }
    return null;
}

function hops(path, sim, platforms, world) {
    let x = sim.x;
    let steps = [];
    for (let index = 1; index < path.length; index++) {
        const next = hop(surface(path[index - 1], sim, platforms, world),
            platforms[path[index]], sim, world, x);
        if (!next)
            return null;
        x = next.x;
        steps = steps.concat(next.steps);
    }
    return steps;
}

function climbTrip(sim, platforms, world, goal) {
    if (sim.platform >= 0)
        return null;
    const left = goal.x <= world.left + sim.width * 0.8;
    const right = goal.x + goal.width >= world.right - sim.width * 0.8;
    if (!left && !right)
        return null;
    const useLeft = left && (!right || sim.x + sim.width / 2 < (world.left + world.right) / 2);
    const range = landingRange(goal, sim, world);
    return [
        { kind: "walk", targetX: useLeft ? world.left : world.right - sim.width },
        { kind: "climb", feet: goal.y, facing: useLeft ? -1 : 1 },
        { kind: "jump", platform: goal.id, targetX: useLeft ? range.left : range.right }
    ];
}

function grappleTrip(sim, platforms, world, goal) {
    const from = surfaceRange(sim, platforms, world);
    const range = landingRange(goal, sim, world);
    const left = Math.max(from.left, range.left);
    const right = Math.min(from.right, range.right);
    if (left > right || from.y - goal.y - world.grip < sim.height * 0.5)
        return null;
    const x = random(left, right);
    return [
        { kind: "walk", targetX: x },
        { kind: "rest", animation: "grapple", duration: 820, grapple: goal.id },
        { kind: "reel", animation: "hang", platform: goal.id },
        { kind: "jump", platform: goal.id, targetX: x }
    ];
}

function burstPoint() {
    return Math.random() < burstChance ? random(0.3, 0.85) : 0;
}

function balloonFlight(sim, from, range, feet, extra) {
    const left = Math.max(from.left, range.left);
    const right = Math.min(from.right, range.right);
    const near = Math.max(range.left, Math.min(range.right, sim.x));
    const launchX = left <= right ? random(left, right)
        : Math.max(from.left, Math.min(from.right, near));
    const targetX = Math.max(range.left, Math.min(range.right, launchX));
    if (Math.abs(targetX - launchX) > (from.y - feet) * 0.2)
        return null;
    const steps = [
        { kind: "rest", animation: "inflate", duration: 1550 },
        Object.assign({ kind: "float", animation: "balloon", feet: feet, targetX: targetX, burst: burstPoint() }, extra)
    ];
    return Math.abs(launchX - sim.x) > 1
        ? [{ kind: "walk", targetX: launchX }].concat(steps) : steps;
}

function balloonTrip(sim, platforms, world, goal) {
    const from = surfaceRange(sim, platforms, world);
    if (from.y - goal.y < sim.height * 1.5)
        return null;
    const range = landingRange(goal, sim, world);
    return balloonFlight(sim, from, range,
        Math.max(world.top + sim.height, goal.y - sim.height * 0.4), {});
}

function dangleTrip(sim, platforms, world, goal, method) {
    const from = surfaceRange(sim, platforms, world);
    const feet = goal.y + goal.height + world.grip;
    if (from.y - feet < sim.height * 0.5 || feet - sim.height < world.top)
        return null;
    const range = {
        left: clampX(world, sim, goal.x - sim.width * 0.3),
        right: clampX(world, sim, goal.x + goal.width - sim.width * 0.7)
    };
    if (range.left > range.right)
        return null;
    let steps = null;
    if (method === "grapple") {
        const left = Math.max(from.left, range.left);
        const right = Math.min(from.right, range.right);
        if (left > right)
            return null;
        steps = [
            { kind: "walk", targetX: random(left, right) },
            { kind: "rest", animation: "grapple", duration: 820, grapple: goal.id, underside: true },
            { kind: "reel", animation: "hang", platform: goal.id }
        ];
    } else if (method === "balloon") {
        steps = balloonFlight(sim, from, range, feet, { grab: true });
    } else if (method === "climb") {
        if (sim.platform >= 0)
            return null;
        const wall = range.left <= world.left ? -1
            : range.right >= world.right - sim.width ? 1 : 0;
        if (wall === 0)
            return null;
        steps = [
            { kind: "walk", targetX: wall < 0 ? world.left : world.right - sim.width },
            { kind: "climb", feet: feet, facing: wall }
        ];
    }
    if (!steps)
        return null;
    return steps.concat([
        { kind: "dangle", duration: random(4000, 9000) },
        { kind: "letgo", glide: world.floor - feet >= crashHeight }
    ]);
}

function perchTrip(sim, platforms, world, method) {
    const feet = surfaceY(sim, platforms, world);
    const span = Math.max(1, world.floor - world.top);
    const goals = landable(platforms, sim, world)
        .filter(platform => platform.id !== sim.platform
            && feet - platform.y > sim.height * 0.5);
    const trips = [];
    for (const goal of goals) {
        const weight = 0.5 + 2.5 * (world.floor - goal.y) / span;
        const methods = [
            ["jump", route(sim, platforms, world, goal), 3],
            ["climb", climbTrip(sim, platforms, world, goal), 2],
            ["grapple", grappleTrip(sim, platforms, world, goal), 2],
            ["balloon", balloonTrip(sim, platforms, world, goal), 1.5]
        ].filter(entry => entry[1] && (!method || entry[0] === method));
        if (method === "dangle")
            continue;
        for (const entry of methods)
            trips.push([entry[1], weight * entry[2]]);
    }
    for (const goal of platforms.filter(platform => platform.active && platform.id !== sim.platform)) {
        const weight = 0.5 + 2.5 * (world.floor - goal.y - goal.height) / span;
        for (const entry of [["grapple", 2], ["balloon", 1.5], ["climb", 2]]) {
            const trip = !method || method === "dangle" || method === entry[0]
                ? dangleTrip(sim, platforms, world, goal, entry[0]) : null;
            if (trip)
                trips.push([trip, weight * entry[1]]);
        }
    }
    return trips.length > 0 ? pick(trips) : null;
}

function edgeOption(sim, platforms, world) {
    const platform = platforms[sim.platform];
    const right = Math.random() < 0.5;
    const targetX = right ? platform.x + platform.width - sim.width * 0.6
        : platform.x - sim.width * 0.4;
    if (targetX < world.left || targetX + sim.width > world.right)
        return null;
    const facing = right ? 1 : -1;
    const steps = [
        { kind: "walk", targetX: targetX },
        { kind: "rest", animation: "teeter", duration: random(1200, 1800), facing: facing }
    ];
    if (Math.random() < 0.3 && world.floor - platform.y < crashHeight)
        return steps.concat([{ kind: "walk", targetX: targetX + facing * sim.width * 0.7 }]);
    return steps.concat([{ kind: "walk", targetX: targetX - facing * sim.width * 0.6 }]);
}

function perchIdles(sim, platforms, world) {
    const platform = platforms[sim.platform];
    const high = world.floor - platform.y > (world.floor - world.top) * 0.35;
    const options = [
        [[{ kind: "rest", animation: "sit", duration: random(6000, 12000) }], 2]
    ];
    if (high)
        options.push([[{ kind: "rest", animation: "lookout", duration: random(5000, 9000) }], 1.5]);
    const edge = edgeOption(sim, platforms, world);
    if (edge)
        options.push([edge, 1]);
    return options;
}

function crashed(sim) {
    return sim.impact >= crashSpeed;
}

function recovery(sim, platforms, world, impact) {
    const steps = [];
    if (impact.crash)
        steps.push({ kind: "rest", animation: "crash", duration: 1200 });
    if (impact.dizzy >= 0.1)
        steps.push({ kind: "rest", animation: "dizzy", duration: 1200 + impact.dizzy * 3800 });
    if (impact.dizzy >= 0.7)
        steps.push({ kind: "walk", animation: "stagger", speed: staggerSpeed, targetX: wanderTarget(sim, platforms, world) });
    else if (impact.dizzy < 0.1 && (impact.crash || impact.slid))
        steps.push({ kind: "rest", animation: "dizzy", duration: 1600 });
    return steps.length > 0 ? steps
        : [{ kind: "rest", animation: "land", duration: 180 }];
}

function approach(sim, platforms, world, x) {
    const range = surfaceRange(sim, platforms, world);
    const targetX = Math.max(range.left, Math.min(range.right, x - sim.width / 2));
    const steps = [{ kind: "rest", animation: "stand", duration: random(3500, 6000) }];
    return Math.abs(targetX - sim.x) > sim.width * 0.5
        ? [{ kind: "walk", targetX: targetX }].concat(steps) : steps;
}

function surfaceY(sim, platforms, world) {
    const platform = sim.platform >= 0 ? platforms[sim.platform] : null;
    return platform ? platform.y : world.floor;
}

function ceilingPokes(sim, platforms, world) {
    const head = surfaceY(sim, platforms, world) - sim.height;
    const range = surfaceRange(sim, platforms, world);
    return platforms
        .filter(platform => {
            const gap = head - platform.y - platform.height;
            return platform.active && platform.id !== sim.platform
                && gap >= sim.height * pokeReach[0]
                && gap <= sim.height * pokeReach[1];
        })
        .map(platform => ({
            platform: platform,
            left: Math.max(range.left, platform.x),
            right: Math.min(range.right, platform.x + platform.width - sim.width)
        }))
        .filter(span => span.left <= span.right)
        .map(span => [
            { kind: "walk", targetX: random(span.left, span.right) },
            { kind: "poke", animation: "poke_up", direction: "up", impact: 130, platform: span.platform.id }
        ]);
}

function pokeOptions(sim, platforms, world) {
    const ceiling = ceilingPokes(sim, platforms, world);
    if (sim.platform >= 0)
        return ceiling.concat([[
            { kind: "poke", animation: "poke_down", direction: "down", impact: 150, platform: sim.platform }
        ]]);
    const feet = world.floor;
    return ceiling.concat(platforms
        .filter(platform => platform.active && platform.y < feet
            && platform.y + platform.height > feet - sim.height)
        .map(platform => {
            const leftX = platform.x - sim.width + 12;
            const rightX = platform.x + platform.width - 12;
            const useLeft = leftX >= world.left
                && (Math.abs(leftX - sim.x) < Math.abs(rightX - sim.x)
                    || rightX + sim.width > world.right);
            const targetX = clampX(world, sim, useLeft ? leftX : rightX);
            return [
                { kind: "walk", targetX: targetX },
                { kind: "poke", animation: "poke", direction: "side", impact: 150, platform: platform.id, facing: useLeft ? 1 : -1 }
            ];
        }));
}

function dropOption(sim, platforms, world) {
    const platform = platforms[sim.platform];
    const goLeft = Math.random() < 0.5;
    const targetX = goLeft ? platform.x - sim.width
        : platform.x + platform.width;
    if (targetX < world.left || targetX + sim.width > world.right)
        return null;
    return { kind: "walk", targetX: targetX };
}

function glideOption(sim, platforms, world) {
    const drop = dropOption(sim, platforms, world);
    if (!drop)
        return null;
    return [
        { kind: "rest", animation: "parachute_hold", duration: 700 },
        { kind: "walk", animation: "parachute_walk", targetX: drop.targetX, glide: true }
    ];
}

function plan(context) {
    const sim = context.sim;
    const platforms = context.platforms;
    const world = context.world;
    const state = context.state;
    const activity = context.activity || 1;
    const calm = state === "sleeping" || state === "attention";
    const rest = state === "idle" ? idleRest(context.media, activity) : {
        kind: "rest",
        animation: restAnimation(state, context.tool, context.night),
        duration: restDuration(state) / (calm ? 1 : activity)
    };

    if (state === "attention")
        return [rest];
    if (state === "ready")
        return pick([[[rest], 4],
            [[{ kind: "walk", targetX: wanderTarget(sim, platforms, world) }, rest], 1]]);

    const options = [];
    const jumps = jumpOptions(sim, platforms, world);
    const pokes = pokeOptions(sim, platforms, world);
    const busy = state === "working" || state === "thinking";

    if (state === "sleeping") {
        options.push([[rest], 8 / activity]);
        options.push([[{ kind: "walk", targetX: wanderTarget(sim, platforms, world) }, rest], 1]);
        if (jumps.length > 0)
            options.push([pick(jumps.map(jump => [jump, 1])).concat([rest]), 1]);
        return pick(options);
    }

    options.push([[rest], (busy ? 5 : 3) / activity]);
    options.push([[{ kind: "walk", targetX: wanderTarget(sim, platforms, world) }]
        .concat(busy ? [rest] : []), 2]);
    if (jumps.length > 0)
        options.push([pick(jumps.map(jump => [jump, 1]))
            .concat(busy ? [rest] : []), busy ? 2 : 2.5]);
    const bounce = bounces(sim, platforms, world);
    if (bounce.length > 0)
        options.push([bounce.concat(busy ? [rest] : []), busy ? 0.5 : 1]);
    if (pokes.length > 0 && !busy)
        options.push([pick(pokes.map(poke => [poke, 1])), 1.5]);
    const trip = perchTrip(sim, platforms, world, "");
    if (trip)
        options.push([trip.concat(busy ? [rest] : []), busy ? 1 : 3]);
    if (sim.platform >= 0 && !busy)
        for (const option of perchIdles(sim, platforms, world))
            options.push(option);
    for (const reaction of context.reactions || [])
        options.push([[{
            kind: "rest",
            animation: reaction,
            duration: random(5000, 9000)
        }].concat(busy ? [rest] : []), busy ? 0.6 : 1.5]);
    if (sim.platform >= 0) {
        const drop = dropOption(sim, platforms, world);
        const deadly = world.floor - platforms[sim.platform].y >= crashHeight;
        if (drop)
            options.push([[drop], deadly ? 0.2 : busy ? 0.5 : 1]);
        const glide = deadly ? glideOption(sim, platforms, world) : null;
        if (glide)
            options.push([glide, busy ? 0.6 : 1.5]);
    }
    return pick(options);
}

function launch(sim, targetX, targetFeet) {
    const startFeet = sim.y + sim.height;
    const apexFeet = Math.min(startFeet, targetFeet) - apexClearance
        - Math.abs(targetX - sim.x) * arcPerDistance;
    const velocityY = -Math.sqrt(2 * gravity * (startFeet - apexFeet));
    const duration = -velocityY / gravity
        + Math.sqrt(2 * (targetFeet - apexFeet) / gravity);
    sim.vx = (targetX - sim.x) / duration;
    sim.vy = velocityY;
    sim.airborne = true;
    sim.platform = -1;
    if (sim.vx !== 0)
        sim.facing = sim.vx > 0 ? 1 : -1;
}

function release(sim, velocityX, velocityY) {
    const speed = Math.hypot(velocityX, velocityY);
    const factor = speed > maxThrowSpeed ? maxThrowSpeed / speed : 1;
    sim.vx = velocityX * factor;
    sim.vy = velocityY * factor;
    sim.airborne = true;
    sim.platform = -1;
}

function land(sim, feet, platform) {
    sim.impact = sim.vy;
    sim.sliding = false;
    sim.gliding = false;
    sim.y = feet - sim.height;
    sim.vx = 0;
    sim.vy = 0;
    sim.airborne = false;
    sim.platform = platform ? platform.id : -1;
    sim.platformX = platform ? platform.x : 0;
}

function follow(sim, platforms) {
    if (sim.airborne || sim.platform < 0)
        return false;
    const platform = platforms[sim.platform];
    if (!platform || !platform.active || !supports(platform, center(sim))) {
        sim.airborne = true;
        sim.platform = -1;
        return true;
    }
    sim.x += platform.x - sim.platformX;
    sim.platformX = platform.x;
    sim.y = platform.y - sim.height;
    if (!supports(platform, center(sim))) {
        sim.airborne = true;
        sim.platform = -1;
        return true;
    }
    return false;
}

function step(sim, platforms, world, dt, motion) {
    if (sim.airborne) {
        const previousFeet = sim.y + sim.height;
        if (sim.sliding) {
            sim.vx = 0;
            sim.stuck = Math.max(0, sim.stuck - dt);
            sim.vy = sim.stuck > 0 ? 0 : Math.min(slideSpeed, sim.vy + slideAccel * dt);
        } else if (sim.gliding) {
            sim.vy = Math.min(sim.vy + gravity * dt, glideSpeed);
        } else {
            sim.vy += gravity * dt;
        }
        sim.x += sim.vx * dt;
        sim.y += sim.vy * dt;

        if (sim.x < world.left || sim.x + sim.width > world.right) {
            const wall = sim.x < world.left ? -1 : 1;
            sim.x = clampX(world, sim, sim.x);
            if (Math.abs(sim.vx) >= splatSpeed) {
                sim.sliding = true;
                sim.stuck = slideGrip;
                sim.facing = wall;
                sim.vx = 0;
                sim.vy = 0;
                return "splat";
            }
            sim.vx = -sim.vx * 0.3;
        }
        if (sim.y < world.top) {
            sim.y = world.top;
            sim.vy = Math.max(0, sim.vy);
        }

        const feet = sim.y + sim.height;
        if (sim.vy > 0) {
            const target = landable(platforms, sim, world).find(platform =>
                previousFeet <= platform.y + 1 && feet >= platform.y
                && supports(platform, center(sim)));
            if (target) {
                land(sim, target.y, target);
                return "landed";
            }
        }
        if (feet >= world.floor) {
            land(sim, world.floor, null);
            return "landed";
        }
        return "";
    }

    if (!motion)
        return "";

    switch (motion.kind) {
    case "climb":
        sim.facing = motion.facing;
        sim.y -= climbSpeed * dt;
        if (sim.y + sim.height <= motion.feet) {
            sim.y = motion.feet - sim.height;
            return "arrived";
        }
        return "";
    case "reel":
        sim.y -= reelSpeed * dt;
        if (sim.y + sim.height <= motion.feet) {
            sim.y = motion.feet - sim.height;
            return "arrived";
        }
        return "";
    case "float": {
        const dx = motion.targetX - sim.x;
        const dy = motion.feet - sim.height - sim.y;
        const remaining = Math.hypot(dx, dy);
        if (motion.length === undefined)
            motion.length = Math.max(1, remaining);
        motion.lift = Math.min(floatSpeed, (motion.lift || 0) + floatLift * dt);
        const advance = Math.min(remaining, motion.lift * dt);
        if (remaining > 0) {
            sim.x += dx / remaining * advance;
            sim.y = Math.max(world.top, sim.y + dy / remaining * advance);
        }
        const left = remaining - advance;
        const burst = motion.burst > 0 && 1 - left / motion.length >= motion.burst;
        if (!burst && left >= 1)
            return "";
        if (!burst && motion.grab)
            return "arrived";
        sim.airborne = true;
        sim.platform = -1;
        sim.vx = burst ? dx / Math.max(1, remaining) * motion.lift : 0;
        sim.vy = burst ? 0 : -120;
        return "popped";
    }
    }

    const walkTarget = motion.targetX;
    const distance = walkTarget - sim.x;
    const advance = (motion.speed || walkSpeed) * dt;
    sim.facing = distance >= 0 ? 1 : -1;
    if (Math.abs(distance) <= advance) {
        sim.x = walkTarget;
    } else {
        sim.x += Math.sign(distance) * advance;
    }

    if (sim.platform >= 0) {
        const platform = platforms[sim.platform];
        if (!platform || !supports(platform, center(sim))) {
            sim.airborne = true;
            sim.platform = -1;
            sim.gliding = !!motion.glide;
            sim.vx = Math.sign(distance) * (sim.gliding ? glideDrift : walkSpeed);
            sim.vy = 0;
            return "fell";
        }
    }
    return sim.x === walkTarget ? "arrived" : "";
}
