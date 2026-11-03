.pragma library

.import "WallpaperAnalysis.js" as WallpaperAnalysis

// The algorithm only considers these predictable edge positions.
// That keeps placement deterministic and cheap enough to understand at a glance.
const ANCHORS = [
    "topLeft", "topCenter", "topRight",
    "middleLeft", "middleRight",
    "bottomLeft", "bottomCenter", "bottomRight"
];

// Public entry point ---------------------------------------------------------

function calculate(request, analysis, cardGap) {
    const bounds = sampleBounds(request);
    const gap = Math.max(1, Math.round(cardGap
        / request.screenWidth * request.sampleWidth));
    const cards = createCards(request);
    const secondaryGroups = [cards.resources, cards.environment, cards.system]
        .filter(group => group.length > 0);

    const primaryCandidates = buildPrimaryCandidates(cards, bounds, request,
        analysis, gap);

    let bestSolution = null;
    let bestScore = -Infinity;

    for (let i = 0; i < primaryCandidates.length; ++i) {
        const primary = primaryCandidates[i];
        const occupied = primary.occupied.slice();
        const placed = [];
        let score = primary.score;

        for (let j = 0; j < secondaryGroups.length; ++j) {
            const placement = bestGroupPlacement([
                verticalLayout(secondaryGroups[j], gap),
                horizontalLayout(secondaryGroups[j], gap)
            ], bounds, request, analysis, occupied, gap);
            if (!placement)
                break;
            occupied.push(placement);
            placed.push(placement);
            score += placement.score;
        }
        if (placed.length < secondaryGroups.length)
            continue;

        score -= horizontalBalancePenalty(occupied, request.sampleWidth);
        if (score > bestScore) {
            bestScore = score;
            bestSolution = occupied;
        }
    }

    if (!bestSolution)
        return null;

    const positions = {};
    for (let i = 0; i < bestSolution.length; ++i)
        copyCardPositions(positions, bestSolution[i], request);

    return { positions: positions };
}

// Placement strategy --------------------------------------------------------

function buildPrimaryCandidates(cards, bounds, request, analysis, gap) {
    const candidates = [];
    const info = [cards.weather, cards.calendar].filter(card => card);

    // First try clock + weather + calendar as one group.
    if (cards.clock && info.length > 0) {
        const joinedLayouts = [
            horizontalLayout([cards.clock].concat(info), gap),
            verticalLayout([cards.clock].concat(info), gap)
        ];
        for (let i = 0; i < joinedLayouts.length; ++i) {
            const placements = placementsForLayout(joinedLayouts[i], bounds,
                request, analysis, [], gap, false);
            for (let j = 0; j < placements.length; ++j) {
                candidates.push({
                    score: placements[j].score + 0.2,
                    occupied: [placements[j]]
                });
            }
        }
    }

    // Also allow the clock to float independently from weather + calendar.
    const groups = info.length === 0 ? [null] : [
        horizontalLayout(info, gap),
        verticalLayout(info, gap)
    ].reduce((all, layout) => all.concat(placementsForLayout(layout, bounds,
        request, analysis, [], gap, false)), []);
    const clocks = !cards.clock ? [null] : placementsForLayout(
        horizontalLayout([cards.clock], 0), bounds, request, analysis, [],
        gap, true);

    for (let groupIndex = 0; groupIndex < groups.length; ++groupIndex) {
        for (let clockIndex = 0; clockIndex < clocks.length; ++clockIndex) {
            const group = groups[groupIndex];
            const clock = clocks[clockIndex];
            if (group && clock && overlaps(group, clock, gap * 2))
                continue;

            candidates.push({
                score: group && clock ? (group.score * 2 + clock.score) / 3
                    : group ? group.score : clock ? clock.score : 0,
                occupied: [group, clock].filter(item => item)
            });
        }
    }

    candidates.sort((a, b) => b.score - a.score);
    return candidates.slice(0, 16);
}

function bestGroupPlacement(layouts, bounds, request, analysis, occupied, gap) {
    let best = null;

    for (let i = 0; i < layouts.length; ++i) {
        const placements = placementsForLayout(layouts[i], bounds, request,
            analysis, occupied, gap, false);
        if (placements.length > 0 && (!best || placements[0].score > best.score))
            best = placements[0];
    }

    return best;
}

function placementsForLayout(layout, bounds, request, analysis, occupied,
        gap, textOnly) {
    const placements = [];

    for (let i = 0; i < ANCHORS.length; ++i) {
        const point = positionAtAnchor(ANCHORS[i], layout, bounds);
        if (!point)
            continue;

        const placement = makePlacement(layout, point.x, point.y,
            request.sampleWidth);
        if (collides(placement, occupied, gap * 2))
            continue;

        placement.score = scorePlacement(placement, analysis, textOnly)
            - centerPenalty(placement, request);
        placements.push(placement);
    }

    placements.sort((a, b) => b.score - a.score
        || a.y - b.y || a.x - b.x);
    return placements;
}

// Scoring -------------------------------------------------------------------

function scorePlacement(placement, analysis, textOnly) {
    let total = 0;
    for (let i = 0; i < placement.cards.length; ++i)
        total += WallpaperAnalysis.score(placement.cards[i], analysis, textOnly);
    return total / placement.cards.length;
}

function centerPenalty(placement, request) {
    const protectedRegion = {
        x: Math.round(request.sampleWidth * 0.25),
        y: Math.round(request.sampleHeight * 0.16),
        width: Math.round(request.sampleWidth * 0.5),
        height: Math.round(request.sampleHeight * 0.68)
    };
    const area = Math.max(1, placement.width * placement.height);
    return intersectionArea(placement, protectedRegion) / area * 5;
}

function horizontalBalancePenalty(groups, sampleWidth) {
    let left = 0;
    for (let i = 0; i < groups.length; ++i) {
        const center = groups[i].x + groups[i].width / 2;
        if (center < sampleWidth / 2)
            ++left;
    }
    return Math.abs(left - (groups.length - left)) * 0.35;
}

// Card model ----------------------------------------------------------------

function createCards(request) {
    const resourceSize = sampleSize(request.resourceSize, request);
    const environmentSize = sampleSize(request.environmentSize, request);
    const enabled = name => request.enabled[name] === true;
    const cards = (names, size) => names.filter(enabled)
        .map(name => namedCard(name, size));
    const single = (name, size) => enabled(name)
        ? namedCard(name, sampleSize(size, request)) : null;

    return {
        clock: single("clock", request.clockSize),
        weather: single("weather", request.weatherSize),
        calendar: single("calendar", request.calendarSize),
        resources: cards(["cpuTemperature", "cpuUsage", "gpuTemperature",
            "gpuUsage"], resourceSize),
        environment: cards(["uvIndex", "humidity", "airQuality"],
            environmentSize),
        system: cards(["networkDownload", "networkUpload", "diskUsage"],
            resourceSize)
    };
}

function namedCard(name, size) {
    return { name: name, width: size.width, height: size.height };
}

function sampleSize(sizeValue, request) {
    return {
        width: Math.max(2, Math.round(sizeValue.width
            / request.screenWidth * request.sampleWidth)),
        height: Math.max(2, Math.round(sizeValue.height
            / request.screenHeight * request.sampleHeight))
    };
}

function sampleBounds(request) {
    const left = clamp(Math.round(request.usableArea.x
        / request.screenWidth * request.sampleWidth), 0, request.sampleWidth);
    const top = clamp(Math.round(request.usableArea.y
        / request.screenHeight * request.sampleHeight), 0, request.sampleHeight);
    const right = clamp(Math.round((request.usableArea.x + request.usableArea.width)
        / request.screenWidth * request.sampleWidth), left, request.sampleWidth);
    const bottom = clamp(Math.round((request.usableArea.y + request.usableArea.height)
        / request.screenHeight * request.sampleHeight), top, request.sampleHeight);

    return { x: left, y: top, width: right - left, height: bottom - top };
}

// Geometry helpers ----------------------------------------------------------

function horizontalLayout(cards, gap) {
    let width = 0;
    let height = 0;
    for (let i = 0; i < cards.length; ++i) {
        width += cards[i].width;
        height = Math.max(height, cards[i].height);
    }
    width += gap * Math.max(0, cards.length - 1);

    let x = 0;
    const result = [];
    for (let i = 0; i < cards.length; ++i) {
        const card = cards[i];
        result.push({
            name: card.name,
            x: x,
            y: Math.round((height - card.height) / 2),
            width: card.width,
            height: card.height
        });
        x += card.width + gap;
    }

    return { width: width, height: height, cards: result, vertical: false };
}

function verticalLayout(cards, gap) {
    let width = 0;
    let height = 0;
    for (let i = 0; i < cards.length; ++i) {
        width = Math.max(width, cards[i].width);
        height += cards[i].height;
    }
    height += gap * Math.max(0, cards.length - 1);

    let y = 0;
    const result = [];
    for (let i = 0; i < cards.length; ++i) {
        const card = cards[i];
        result.push({
            name: card.name,
            x: 0,
            y: y,
            width: card.width,
            height: card.height
        });
        y += card.height + gap;
    }

    return { width: width, height: height, cards: result, vertical: true };
}

function positionAtAnchor(anchor, layout, bounds) {
    if (layout.width > bounds.width || layout.height > bounds.height)
        return null;

    const left = bounds.x;
    const centerX = Math.round(bounds.x + (bounds.width - layout.width) / 2);
    const right = bounds.x + bounds.width - layout.width;
    const top = bounds.y;
    const centerY = Math.round(bounds.y + (bounds.height - layout.height) / 2);
    const bottom = bounds.y + bounds.height - layout.height;

    switch (anchor) {
    case "topLeft": return { x: left, y: top };
    case "topCenter": return { x: centerX, y: top };
    case "topRight": return { x: right, y: top };
    case "middleLeft": return { x: left, y: centerY };
    case "middleRight": return { x: right, y: centerY };
    case "bottomLeft": return { x: left, y: bottom };
    case "bottomCenter": return { x: centerX, y: bottom };
    case "bottomRight": return { x: right, y: bottom };
    }
    return null;
}

function makePlacement(layout, x, y, sampleWidth) {
    const alignRight = layout.vertical
        && x + layout.width / 2 >= sampleWidth / 2;
    const cards = [];

    for (let i = 0; i < layout.cards.length; ++i) {
        const card = layout.cards[i];
        cards.push({
            name: card.name,
            x: x + (layout.vertical && alignRight
                ? layout.width - card.width : card.x),
            y: y + card.y,
            width: card.width,
            height: card.height
        });
    }

    return {
        x: x,
        y: y,
        width: layout.width,
        height: layout.height,
        cards: cards,
        score: 0
    };
}

function copyCardPositions(target, placement, request) {
    for (let i = 0; i < placement.cards.length; ++i) {
        const card = placement.cards[i];
        target[card.name] = {
            xRatio: card.x / request.sampleWidth,
            yRatio: card.y / request.sampleHeight
        };
    }
}

function collides(candidate, occupied, margin) {
    for (let i = 0; i < occupied.length; ++i) {
        if (overlaps(candidate, occupied[i], margin))
            return true;
    }
    return false;
}

function overlaps(a, b, margin) {
    return a.x < b.x + b.width + margin
        && a.x + a.width + margin > b.x
        && a.y < b.y + b.height + margin
        && a.y + a.height + margin > b.y;
}

function intersectionArea(a, b) {
    const width = Math.max(0,
        Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x));
    const height = Math.max(0,
        Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y));
    return width * height;
}

function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, value));
}
