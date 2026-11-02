.pragma library

const gravity = 2400;
const walkSpeed = 140;
const apexClearance = 70;
const maxThrowSpeed = 1800;
const edgeMargin = 0.3;
const pokeReach = [0.35, 0.9];
const jumpReach = 2.5;
const jumpRise = 5;
const arcPerDistance = 0.35;

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

function surfaceRange(sim, platforms, world) {
    const platform = sim.platform >= 0 ? platforms[sim.platform] : null;
    if (!platform)
        return { left: world.left, right: world.right - sim.width };
    return {
        left: Math.max(world.left, platform.x - sim.width * edgeMargin),
        right: Math.min(world.right - sim.width,
            platform.x + platform.width - sim.width * (1 - edgeMargin))
    };
}

function wanderTarget(sim, platforms, world) {
    const range = surfaceRange(sim, platforms, world);
    return random(range.left, Math.max(range.left, range.right));
}

function jumpOptions(sim, platforms, world) {
    const feet = surfaceY(sim, platforms, world);
    const range = surfaceRange(sim, platforms, world);
    const reach = sim.width * jumpReach;
    return landable(platforms, sim, world)
        .filter(platform => platform.id !== sim.platform
            && feet - platform.y <= sim.height * jumpRise)
        .map(platform => {
            const targetX = clampX(world, sim, random(platform.x,
                Math.max(platform.x, platform.x + platform.width - sim.width)));
            const launchX = Math.max(range.left, Math.min(range.right,
                Math.max(targetX - reach, Math.min(targetX + reach, sim.x))));
            if (Math.abs(targetX - launchX) > reach)
                return null;
            const jump = { kind: "jump", platform: platform.id, targetX: targetX };
            return Math.abs(launchX - sim.x) > 1
                ? [{ kind: "walk", targetX: launchX }, jump] : [jump];
        })
        .filter(option => option);
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
    if (pokes.length > 0 && !busy)
        options.push([pick(pokes.map(poke => [poke, 1])), 1.5]);
    for (const reaction of context.reactions || [])
        options.push([[{
            kind: "rest",
            animation: reaction,
            duration: random(5000, 9000)
        }].concat(busy ? [rest] : []), busy ? 0.6 : 1.5]);
    if (sim.platform >= 0) {
        const drop = dropOption(sim, platforms, world);
        if (drop)
            options.push([[drop], busy ? 0.5 : 1.5]);
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

function step(sim, platforms, world, dt, walkTarget) {
    if (sim.airborne) {
        const previousFeet = sim.y + sim.height;
        sim.vy += gravity * dt;
        sim.x += sim.vx * dt;
        sim.y += sim.vy * dt;

        if (sim.x < world.left || sim.x + sim.width > world.right) {
            sim.x = clampX(world, sim, sim.x);
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

    if (walkTarget === undefined)
        return "";

    const distance = walkTarget - sim.x;
    const advance = walkSpeed * dt;
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
            sim.vx = Math.sign(distance) * walkSpeed;
            sim.vy = 0;
            return "fell";
        }
    }
    return sim.x === walkTarget ? "arrived" : "";
}
