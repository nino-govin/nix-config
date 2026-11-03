import math
import os
import random
import struct
import wave

RATE = 22050
SOFTEN = 0.45
NOTES = {"C5": 523.25, "D5": 587.33, "E5": 659.25, "G5": 783.99, "A5": 880.0, "C6": 1046.5, "E6": 1318.5}


def osc(shape, f0, f1, duration, duty=0.5, vibrato=0.0, rate=0.0, seed=1):
    count = int(duration * RATE)
    rng = random.Random(seed)
    phase, held, out = 0.0, rng.uniform(-1, 1), []
    for index in range(count):
        t = index / max(count - 1, 1)
        freq = f0 * (f1 / f0) ** t
        if vibrato:
            freq *= 1 + vibrato * math.sin(2 * math.pi * rate * index / RATE)
        previous = phase
        phase = (phase + freq / RATE) % 1
        if shape == "square":
            value = 1.0 if phase < duty else -1.0
        elif shape == "triangle":
            value = 4 * abs(phase - 0.5) - 1
        elif shape == "sine":
            value = math.sin(2 * math.pi * phase)
        else:
            if phase < previous:
                held = rng.uniform(-1, 1)
            value = held
        out.append(value)
    return out


def env(samples, attack=0.005, decay=6.0, hold=0.0):
    count = len(samples)
    out = []
    for index, value in enumerate(samples):
        t = index / RATE
        gain = min(1.0, t / attack) if attack > 0 else 1.0
        if t > hold:
            gain *= math.exp(-decay * (t - hold) / max(count / RATE, 1e-3))
        out.append(value * gain)
    return out


def tremolo(samples, rate, depth=1.0):
    return [value * (1 - depth * (0.5 + 0.5 * math.sin(2 * math.pi * rate * index / RATE)))
            for index, value in enumerate(samples)]


def lowpass(samples, alpha):
    out, last = [], 0.0
    for value in samples:
        last += alpha * (value - last)
        out.append(last)
    return out


def gain(samples, level):
    return [value * level for value in samples]


def mix(*parts):
    length = max(int(offset * RATE) + len(samples) for offset, samples in parts)
    out = [0.0] * length
    for offset, samples in parts:
        start = int(offset * RATE)
        for index, value in enumerate(samples):
            out[start + index] += value
    return out


def seq(*parts, gap=0.0):
    offset, placed = 0.0, []
    for samples in parts:
        placed.append((offset, samples))
        offset += len(samples) / RATE + gap
    return mix(*placed)


def level(samples, peak):
    top = max(abs(value) for value in samples) or 1.0
    return [value * peak / top for value in samples]


def blip(f0, f1, duration, shape="square", duty=0.5, decay=4.0, **extra):
    return env(osc(shape, f0, f1, duration, duty, **extra), decay=decay)


def noise(f0, f1, duration, decay=5.0, attack=0.002, alpha=1.0, seed=1):
    return lowpass(env(osc("noise", f0, f1, duration, seed=seed), attack=attack, decay=decay), alpha)


def chord(*freqs, duration=0.15, shape="triangle", decay=5.0):
    return mix(*[(0, blip(f, f, duration, shape, decay=decay)) for f in freqs])


def note(freq, duration=0.16):
    return mix((0, blip(freq, freq, duration, "triangle", decay=5)),
               (0, gain(blip(freq, freq, duration * 0.6, "square", decay=7), 0.12)))


def rain():
    rng = random.Random(7)
    return mix(*[(rng.uniform(0, 1.0), noise(9000, 6000, 0.02, decay=8, seed=index))
                 for index in range(14)])


SOUNDS = {
    "attention": (0.75, lambda: seq(
        note(440, 0.08), note(NOTES["E5"], 0.1),
        [0.0] * int(0.08 * RATE),
        note(440, 0.08), note(NOTES["E5"], 0.14), gap=0.015)),
    "ready": (0.7, lambda: seq(
        note(NOTES["C5"], 0.07), note(NOTES["E5"], 0.07), note(NOTES["G5"], 0.07), note(NOTES["C6"], 0.32), gap=0.01)),
    "wake": (0.45, lambda: seq(note(392, 0.08), note(NOTES["C5"], 0.08), note(NOTES["E5"], 0.2))),
    "grab": (0.5, lambda: seq(blip(260, 440, 0.07, "triangle", decay=1), blip(440, 380, 0.07, "triangle", decay=4))),
    "shake_1": (0.4, lambda: mix((0, noise(5000, 2000, 0.03)), (0, blip(320, 260, 0.06)))),
    "shake_2": (0.45, lambda: mix((0, noise(6000, 2500, 0.03)), (0, blip(420, 340, 0.06)))),
    "shake_3": (0.5, lambda: mix((0, noise(7000, 3000, 0.03)), (0, blip(560, 440, 0.06)))),
    "throw": (0.4, lambda: noise(1500, 5000, 0.28, decay=4, attack=0.08, alpha=0.4)),
    "boop": (0.5, lambda: mix((0, blip(660, 440, 0.09, "triangle")), (0, gain(blip(1320, 880, 0.04), 0.2)))),
    "dizzy": (0.35, lambda: seq(*[blip(800 + 100 * k, 1100 + 100 * k, 0.05, "triangle", decay=3) for k in range(3)], gap=0.04)),
    "splat": (0.7, lambda: mix((0, noise(2500, 300, 0.2, decay=5, alpha=0.5)), (0, blip(240, 60, 0.16, duty=0.5)))),
    "scrape": (0.3, lambda: mix((0, noise(6000, 4000, 0.25, decay=3, alpha=0.6)), (0, gain(blip(900, 700, 0.18, decay=3), 0.4)))),
    "crash": (0.8, lambda: mix(
        (0, blip(140, 40, 0.28, "sine", decay=4)), (0, noise(900, 100, 0.22, alpha=0.5)),
        (0.24, gain(blip(1000, 1000, 0.15, "triangle"), 0.5)), (0.38, gain(blip(1200, 1200, 0.15, "triangle"), 0.4)))),
    "jump": (0.2, lambda: blip(220, 660, 0.13, decay=4)),
    "land": (0.45, lambda: mix((0, noise(600, 100, 0.07, alpha=0.5)), (0, blip(160, 60, 0.08, "triangle")))),
    "boing": (0.5, lambda: blip(220, 520, 0.35, "triangle", decay=4, vibrato=0.08, rate=18)),
    "whoosh": (0.35, lambda: noise(1200, 4000, 0.2, decay=3, attack=0.05, alpha=0.4)),
    "clink": (0.4, lambda: seq(blip(800, 800, 0.04, "triangle"), blip(1100, 1100, 0.1, "triangle"))),
    "ratchet": (0.22, lambda: mix((0, noise(8000, 8000, 0.015, decay=4)), (0, blip(600, 550, 0.012, "triangle")))),
    "inflate": (0.35, lambda: seq(*[mix((0, noise(2000, 1500, 0.12, decay=4, alpha=0.5)),
                                        (0.02, gain(blip(200 * 1.2 ** k, 230 * 1.2 ** k, 0.14, "triangle", decay=3), 0.6)))
                                    for k in range(5)], gap=0.16)),
    "pop": (0.7, lambda: mix((0, noise(9000, 3000, 0.08)), (0, blip(600, 100, 0.06)))),
    "parachute": (0.4, lambda: noise(300, 900, 0.25, decay=4, attack=0.03, alpha=0.3)),
    "climb": (0.2, lambda: noise(5000, 4000, 0.025)),
    "whoa": (0.3, lambda: blip(700, 450, 0.4, "triangle", decay=3, vibrato=0.12, rate=6)),
    "step": (0.18, lambda: mix((0, blip(120, 80, 0.025, "triangle")), (0, gain(noise(3000, 3000, 0.01), 0.3)))),
    "snore": (0.25, lambda: seq(
        tremolo(env(lowpass(osc("noise", 150, 200, 0.7), 0.3), attack=0.4, decay=3), 30, 0.6),
        gain(blip(500, 650, 0.3, "sine", decay=3), 0.25), gap=0.1)),
    "key_1": (0.18, lambda: mix((0, noise(7000, 7000, 0.012)), (0, blip(900, 850, 0.008, "triangle")))),
    "key_2": (0.16, lambda: mix((0, noise(6000, 6000, 0.012)), (0, blip(750, 700, 0.008, "triangle")))),
    "clack": (0.22, lambda: mix((0, noise(4000, 3000, 0.02)), (0, blip(500, 450, 0.015, "triangle")))),
    "beep": (0.2, lambda: blip(660, 660, 0.06, "triangle", decay=1)),
    "blip": (0.2, lambda: blip(440, 660, 0.05, "triangle")),
    "hmm": (0.25, lambda: blip(300, 420, 0.35, "triangle", decay=3, vibrato=0.03, rate=7)),
    "modem": (0.12, lambda: [value * (1 if (index // int(0.02 * RATE)) % 2 else 0.6)
                             for index, value in enumerate(env(osc("triangle", 600, 1000, 0.3), decay=2))]),
    "note_1": (0.22, lambda: note(NOTES["C5"])),
    "note_2": (0.22, lambda: note(NOTES["D5"])),
    "note_3": (0.22, lambda: note(NOTES["E5"])),
    "note_4": (0.22, lambda: note(NOTES["G5"])),
    "note_5": (0.22, lambda: note(NOTES["A5"])),
    "think": (0.2, lambda: blip(400, 800, 0.07, "sine", decay=3)),
    "equip": (0.22, lambda: seq(blip(400, 550, 0.04, "triangle"), blip(700, 700, 0.05, "triangle"))),
    "unequip": (0.2, lambda: seq(blip(700, 550, 0.04, "triangle"), blip(400, 400, 0.05, "triangle"))),
    "flip": (0.2, lambda: noise(3000, 6000, 0.12, decay=3, attack=0.03, alpha=0.6)),
    "slurp": (0.2, lambda: tremolo(noise(600, 1400, 0.4, decay=2, attack=0.05, alpha=0.4), 14, 0.7)),
    "ahh": (0.2, lambda: blip(500, 400, 0.3, "triangle", decay=3, vibrato=0.03, rate=6)),
    "pop_small": (0.2, lambda: mix((0, blip(700, 300, 0.03, "triangle")), (0, noise(8000, 8000, 0.01)))),
    "blow": (0.15, lambda: noise(1500, 1200, 0.4, decay=2, attack=0.1, alpha=0.4)),
    "tap_1": (0.18, lambda: blip(330, 330, 0.04, "triangle")),
    "tap_2": (0.18, lambda: blip(392, 392, 0.04, "triangle")),
    "tap_3": (0.18, lambda: blip(440, 440, 0.04, "triangle")),
    "tap_4": (0.18, lambda: blip(523, 523, 0.04, "triangle")),
    "scratch": (0.15, lambda: noise(4000, 3000, 0.04, decay=3)),
    "fan": (0.15, lambda: tremolo(env(lowpass(osc("noise", 400, 400, 1.2), 0.3), attack=0.05, decay=0.5), 20, 0.5)),
    "yawn": (0.2, lambda: blip(600, 250, 1.0, "triangle", decay=2, vibrato=0.04, rate=5)),
    "charge_0": (0.2, lambda: blip(261, 261, 0.05, "triangle")),
    "charge_1": (0.2, lambda: blip(329, 329, 0.05, "triangle")),
    "charge_2": (0.2, lambda: blip(392, 392, 0.05, "triangle")),
    "charge_3": (0.2, lambda: blip(494, 494, 0.05, "triangle")),
    "charge_4": (0.22, lambda: chord(523.25, 784, duration=0.3)),
    "rain": (0.15, rain),
    "ching": (0.2, lambda: chord(1300, 1950, duration=0.4, decay=4)),
    "brr": (0.2, lambda: tremolo(blip(110, 100, 0.5, duty=0.5, decay=2), 25, 0.8)),
    "toss": (0.15, lambda: blip(450, 600, 0.03, "triangle")),
    "catch": (0.2, lambda: mix((0, noise(1200, 400, 0.04)), (0, blip(200, 150, 0.04, "triangle")))),
    "spot": (0.2, lambda: blip(500, 750, 0.06, "triangle")),
    "plop": (0.2, lambda: blip(300, 150, 0.05, "triangle", decay=3)),
    "curious": (0.25, lambda: blip(500, 800, 0.12, "triangle", decay=2)),
}


def write(path, samples):
    with wave.open(path, "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        fade = int(0.004 * RATE)
        for index in range(min(fade, len(samples))):
            samples[-1 - index] *= index / fade
        handle.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, value)) * 32767))
                                    for value in samples))


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    target = os.path.join(os.path.dirname(here), "sounds")
    os.makedirs(target, exist_ok=True)
    for name in os.listdir(target):
        if name.endswith(".wav") and name[:-4] not in SOUNDS:
            os.remove(os.path.join(target, name))
    for name, (peak, build) in SOUNDS.items():
        write(os.path.join(target, name + ".wav"), level(lowpass(build(), SOFTEN), peak))
    print(f"{len(SOUNDS)} sounds -> {target}")


if __name__ == "__main__":
    main()
