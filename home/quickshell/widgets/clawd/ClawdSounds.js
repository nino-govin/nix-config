.pragma library

const groups = {
    alerts: ["attention", "ready"],
    handling: ["grab", "shake_1", "shake_2", "shake_3", "throw", "boop", "dizzy", "splat", "scrape", "crash"],
    stunts: ["jump", "land", "boing", "whoosh", "clink", "ratchet", "inflate", "pop", "parachute", "climb", "whoa"],
    ambient: ["wake", "step", "snore", "key_1", "key_2", "clack", "beep", "blip", "hmm", "modem",
        "note_1", "note_2", "note_3", "note_4", "note_5", "think", "equip", "unequip", "flip", "slurp", "ahh",
        "pop_small", "blow", "tap_1", "tap_2", "tap_3", "tap_4", "scratch", "fan", "yawn",
        "charge_0", "charge_1", "charge_2", "charge_3", "charge_4", "rain", "ching", "brr", "toss", "catch",
        "spot", "plop", "curious"]
};

const gaps = {
    jump: 600,
    scrape: 400,
    parachute: 3000,
    whoa: 1500,
    modem: 3000,
    think: 2500,
    ching: 5000,
    brr: 1500
};

const cues = {
    walk: { 0: "step", 2: "step" },
    stagger: { 0: "step", 2: "dizzy", 4: "step", 6: "dizzy" },
    parachute_walk: { 0: "step", 2: "step" },
    sleep: { 0: "snore" },
    nightcap: { 0: "snore" },
    jump: { 0: "jump" },
    land: { 0: "land" },
    crash: { 0: "crash" },
    splat: { 0: "splat" },
    slide: { 0: "scrape" },
    slide_fast: { 0: "scrape" },
    dizzy: { 0: "dizzy", 4: "dizzy" },
    shaken_1: { 0: "dizzy" },
    shaken_2: { 0: "dizzy", 4: "dizzy" },
    shaken_3: { 0: "dizzy", 4: "dizzy" },
    grapple: { 0: "whoosh" },
    hang: { 0: "ratchet", 1: "ratchet" },
    inflate: { 0: "inflate" },
    balloon_out: { 0: "pop" },
    parachute: { 0: "parachute" },
    climb: { 0: "climb", 2: "climb" },
    teeter: { 0: "whoa" },
    sit_in: { 1: "plop" },
    idle_read_in: { 2: "plop" },
    work_read_in: { 0: "equip" },
    work_write_in: { 0: "equip" },
    work_bash_in: { 0: "equip" },
    work_web_in: { 0: "equip" },
    work_agent_in: { 0: "equip" },
    work_read_out: { 0: "unequip" },
    work_write_out: { 0: "unequip" },
    work_bash_out: { 0: "unequip" },
    work_web_out: { 0: "unequip" },
    work_agent_out: { 0: "unequip" },
    work_read: { 4: "hmm" },
    work_write: { 0: "key_1", 1: "key_2", 2: "key_1", 4: "key_2", 5: "key_1" },
    work_bash: { 0: "clack", 1: "clack", 2: "clack", 3: "beep", 4: "blip" },
    work_web: { 0: "modem" },
    work_agent: { 0: "note_1", 1: "note_3", 2: "note_5", 3: "note_3" },
    think: { 0: "think" },
    idle_read: { 6: "flip", 14: "flip" },
    idle_coffee: { 3: "slurp", 5: "ahh" },
    idle_music: { 0: "note_1", 2: "note_3", 4: "note_2", 6: "note_4" },
    idle_bubbles: { 1: "blow", 6: "pop_small", 8: "pop_small", 10: "pop_small" },
    idle_mania: { 0: "tap_1", 2: "tap_3", 4: "tap_2", 6: "tap_4", 8: "tap_1", 10: "tap_2", 12: "tap_3", 14: "tap_4" },
    idle_look: { 5: "scratch", 7: "scratch" },
    fan: { 0: "fan" },
    yawn: { 2: "yawn" },
    charge: { 0: "charge_0", 1: "charge_1", 2: "charge_2", 3: "charge_3", 4: "charge_4" },
    umbrella: { 0: "rain" },
    sunglasses: { 0: "ching" },
    snow: { 0: "brr" },
    packets: { 4: "catch", 8: "toss" },
    juggle: { 0: "toss", 2: "toss", 4: "toss" },
    lookout: { 5: "spot" }
};

function group(name) {
    for (const key in groups) {
        if (groups[key].indexOf(name) !== -1)
            return key;
    }
    return "";
}

function cue(tag, frame) {
    const entry = cues[tag];
    return entry && entry[frame] ? entry[frame] : "";
}
