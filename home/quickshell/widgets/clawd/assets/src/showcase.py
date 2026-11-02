import os
import subprocess
import tempfile

from clawd import ANIMATIONS, FRAME
from pix import PALETTE

SCALE = 3
COLUMNS = 6
LABEL = 8
TICK = 50
LENGTH = 9000
BACKGROUND = (46, 52, 64)
TEXT = "#D8DEE9"

CELLS = [
    ("stand", ["stand"]),
    ("walk", ["walk"]),
    ("jump", ["jump"]),
    ("fall", ["fall"]),
    ("land", ["land", "stand"]),
    ("grabbed", ["grabbed"]),
    ("sleep", ["sleep"]),
    ("nightcap", ["nightcap"]),
    ("poke", ["poke"]),
    ("poke_down", ["poke_down"]),
    ("poke_up", ["poke_up"]),
    ("think", ["think"]),
    ("idle_look", ["idle_look"]),
    ("idle_read", ["idle_read_in", "idle_read", "idle_read_out"]),
    ("idle_coffee", ["idle_coffee_in", "idle_coffee"]),
    ("idle_music", ["idle_music"]),
    ("idle_bubbles", ["idle_bubbles"]),
    ("idle_mania", ["idle_mania"]),
    ("work_read", ["work_read_in", "work_read", "work_read", "work_read_out"]),
    ("work_write", ["work_write_in", "work_write", "work_write", "work_write_out"]),
    ("work_bash", ["work_bash_in", "work_bash", "work_bash", "work_bash_out"]),
    ("work_web", ["work_web_in", "work_web", "work_web_out"]),
    ("work_agent", ["work_agent_in", "work_agent", "work_agent", "work_agent_out"]),
    ("attention", ["attention"]),
    ("peek", ["peek_in", "peek", "peek", "peek_out", "gone"]),
    ("fan", ["fan"]),
    ("yawn", ["yawn"]),
    ("charge", ["charge"]),
    ("umbrella", ["umbrella"]),
    ("sunglasses", ["sunglasses"]),
    ("snow", ["snow"]),
    ("packets", ["packets"]),
    ("juggle", ["juggle"]),
    ("watch", ["watch_left", "watch_upleft", "watch_up", "watch_upright", "watch_right", "watch_down"]),
    ("teeter", ["teeter"]),
    ("sit", ["sit_in", "sit", "sit_out"]),
    ("lookout", ["lookout"]),
    ("climb", ["climb"]),
    ("grapple", ["grapple", "hang", "hang"]),
    ("dangle", ["dangle"]),
    ("balloon", ["inflate", "balloon", "balloon", "balloon_out"]),
    ("parachute", ["parachute_hold", "parachute_walk", "parachute"]),
    ("shaken", ["shaken_1", "shaken_2", "shaken_3"]),
    ("dizzy", ["dizzy", "stagger"]),
    ("crash", ["crash"]),
    ("splat", ["splat", "slide", "slide", "slide_fast", "slide_fast"]),
]

TAGS = dict(ANIMATIONS)
COLORS = {key: tuple(int(value[i:i + 2], 16) for i in (1, 3, 5)) for key, value in PALETTE.items()}


def font():
    return subprocess.run(
        ["fc-match", "-f", "%{file}", "monospace:bold"],
        check=True, capture_output=True, text=True,
    ).stdout


def timeline(tags):
    frames = [entry for tag in tags for entry in TAGS[tag]]
    total = sum(duration for _, duration in frames)
    return frames, total


def at(frames, total, time):
    time %= total
    for rows, duration in frames:
        if time < duration:
            return rows
        time -= duration
    return frames[-1][0]


def blank(width, height):
    return [[BACKGROUND] * width for _ in range(height)]


def blit(image, rows, x0, y0):
    for y, row in enumerate(rows):
        for x, key in enumerate(row):
            if key != ".":
                image[y0 + y][x0 + x] = COLORS[key]


def write_ppm(path, image):
    height, width = len(image), len(image[0])
    with open(path, "wb") as handle:
        handle.write(b"P6 %d %d 255\n" % (width, height))
        handle.write(bytes(channel for row in image for pixel in row for channel in pixel))


def labels(entries):
    args = ["-font", font(), "-pointsize", "13", "-fill", TEXT]
    for text, x, y in entries:
        args += ["-annotate", f"+{x}+{y}", text]
    return args


def showcase(out):
    rows = (len(CELLS) + COLUMNS - 1) // COLUMNS
    cell = FRAME + LABEL
    timelines = [timeline(tags) for _, tags in CELLS]
    places = [(index % COLUMNS * FRAME, index // COLUMNS * cell) for index in range(len(CELLS))]
    texts = [
        (name, x * SCALE + (FRAME * SCALE - len(name) * 8) // 2, (y + FRAME) * SCALE + 10)
        for (name, _), (x, y) in zip(CELLS, places)
    ]
    with tempfile.TemporaryDirectory() as staging:
        for tick in range(LENGTH // TICK):
            image = blank(COLUMNS * FRAME, rows * cell)
            for (frames, total), (x, y) in zip(timelines, places):
                blit(image, at(frames, total, tick * TICK), x, y)
            write_ppm(os.path.join(staging, f"{tick:04d}.ppm"), image)
        subprocess.run(
            ["magick", "-delay", str(TICK // 10), "-loop", "0", os.path.join(staging, "*.ppm"),
             "-scale", f"{SCALE * 100}%"] + labels(texts) + ["-layers", "Optimize", out],
            check=True,
        )


def sheet(out):
    names = [name for name, _ in ANIMATIONS]
    width = max(len(frames) for _, frames in ANIMATIONS) * FRAME
    gutter = 40
    image = blank(gutter + width, len(names) * FRAME)
    for row, (_, frames) in enumerate(ANIMATIONS):
        for column, (rows, _) in enumerate(frames):
            blit(image, rows, gutter + column * FRAME, row * FRAME)
    texts = [(name, 6, row * FRAME * SCALE + FRAME * SCALE // 2 + 4) for row, name in enumerate(names)]
    with tempfile.TemporaryDirectory() as staging:
        source = os.path.join(staging, "sheet.ppm")
        write_ppm(source, image)
        subprocess.run(["magick", source, "-scale", f"{SCALE * 100}%"] + labels(texts) + [out], check=True)


def main():
    assets = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    showcase(os.path.join(assets, "showcase.gif"))
    sheet(os.path.join(assets, "frames.png"))


if __name__ == "__main__":
    main()
