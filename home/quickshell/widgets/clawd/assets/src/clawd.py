import json
import math
import os
import subprocess
import tempfile

from pix import PALETTE, Canvas

FRAME = 64
ORIGIN = (12, 32)
BODY = (14, 37, 36, 23)
LEGS = (9, 15, 23, 29)
GROUND = 26


def arm(c, side, style, top):
    left = side == "left"
    if style == "none":
        return
    fill = "B" if left else "D"
    if style == "up":
        x0 = 3 if left else 34
        c.rect(x0, top - 3, x0 + 2, top + 3, fill)
        c.rect(x0, top - 3, x0 + 2, top - 3, "H" if left else "D")
    elif style == "down":
        x0 = 3 if left else 34
        c.rect(x0, top + 9, x0 + 2, top + 13, fill)
        c.rect(x0, top + 13, x0 + 2, top + 13, "D" if left else "M")
    else:
        x0 = 2 if left else 34
        ay = top + 7 + (style if isinstance(style, int) else 0)
        c.rect(x0, ay, x0 + 3, ay + 3, fill)
        if left:
            c.rect(x0, ay, x0 + 3, ay, "H")
            c.rect(x0, ay + 3, x0 + 3, ay + 3, "D")


def eye(c, ex, top, style, left):
    if style == "none":
        return
    if style == "left":
        c.rect(ex - 1, top + 4, ex + 1, top + 7, "E")
        c.px(ex - 1, top + 4, "W")
    elif style == "right":
        c.rect(ex + 1, top + 4, ex + 3, top + 7, "E")
        c.px(ex + 1, top + 4, "W")
    elif style == "up":
        c.rect(ex, top + 3, ex + 2, top + 5, "E")
        c.px(ex, top + 3, "W")
    elif style == "down":
        c.rect(ex, top + 6, ex + 2, top + 8, "E")
        c.px(ex, top + 6, "W")
    elif style == "open":
        c.rect(ex, top + 4, ex + 2, top + 7, "E")
        c.px(ex, top + 4, "W")
    elif style == "wide":
        c.rect(ex, top + 3, ex + 2, top + 8, "E")
        c.rect(ex, top + 3, ex, top + 4, "W")
    elif style == "upleft":
        c.rect(ex - 1, top + 3, ex + 1, top + 5, "E")
        c.px(ex - 1, top + 3, "W")
    elif style == "upright":
        c.rect(ex + 1, top + 3, ex + 3, top + 5, "E")
        c.px(ex + 1, top + 3, "W")
    elif style == "x":
        for dx, dy in ((0, 0), (2, 0), (1, 1), (0, 2), (2, 2)):
            c.px(ex + dx, top + 4 + dy, "E")
    elif style == "squint":
        points = [(0, 0), (1, 1), (2, 2), (1, 3), (0, 4)]
        for dx, dy in points:
            c.px(ex + (dx if left else 2 - dx), top + 3 + dy, "E")
    else:
        c.rect(ex - 1, top + 7, ex + 3, top + 7, "E")


def crab(dy=0, lifts=(0, 0, 0, 0), eyes="open", arms=(0, 0)):
    c = Canvas(40, 34)
    top, bottom = 6 + dy, 21 + dy
    c.rect(6, top, 33, bottom, "B")
    for x, y in ((6, top), (33, top), (6, bottom), (33, bottom)):
        c.px(x, y, ".")
    c.rect(7, top, 32, top, "H")
    c.rect(6, top + 1, 6, bottom - 1, "H")
    c.px(7, top + 1, "H")
    c.rect(7, bottom, 32, bottom, "D")
    c.rect(33, top + 1, 33, bottom - 1, "D")
    c.px(32, bottom - 1, "D")
    left_eye, right_eye = eyes if isinstance(eyes, tuple) else (eyes, eyes)
    eye(c, 12, top, left_eye, True)
    eye(c, 25, top, right_eye, False)
    arm(c, "left", arms[0], top)
    arm(c, "right", arms[1], top)
    for lx, lift in zip(LEGS, lifts):
        end = GROUND - lift
        if end > bottom:
            c.rect(lx, bottom + 1, lx + 1, end, "D")
            c.rect(lx, end, lx + 1, end, "M")
    return c.outline()


def glyph(rows):
    c = Canvas(len(rows[0]), len(rows))
    c.rows(0, 0, rows)
    return c


Z_SMALL = glyph(["WWWW", "..W.", ".W..", "WWWW"])
Z_LARGE = glyph(["WWWWW", "...W.", "..W..", ".W...", "WWWWW"])


def prop(rows, outline=True):
    c = Canvas(len(rows[0]) + 2, len(rows) + 2)
    c.rows(1, 1, rows)
    return c.outline() if outline else c


BUBBLE = [
    ".WWWWWWWWWW.",
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW",
    ".WWWWWWWWWW.",
]


def bubble(dots):
    rows = [list(row) for row in BUBBLE]
    for index in range(dots):
        for dy in (2, 3):
            for dx in (0, 1):
                rows[dy][2 + index * 3 + dx] = "E"
    return prop(["".join(row) for row in rows])


TRAIL_SMALL = prop(["WW", "WW"])
TRAIL_TINY = prop(["W"])


DEERSTALKER = prop([
    "......TTTTTT......",
    "....TTtTTtTTtT....",
    "...TtTTtTTtTTtT...",
    "..TTTTTTTTTTTTTT..",
    "..TtTTtTTtTTtTTT..",
    ".tttttttttttttttt.",
    "tt..............tt",
])

QUESTION = prop([
    ".WWWWWWW.",
    "WWWEEEWWW",
    "WWEWWWEWW",
    "WWWWWEEWW",
    "WWWWEWWWW",
    "WWWWWWWWW",
    "WWWWEWWWW",
    ".WWWWWWW.",
    "....WW...",
    ".....W...",
])

CLAW_GRIP = prop([
    "..BBBH.",
    ".BBBBBH",
    ".....BB",
    ".....BB",
    ".BBBBBB",
    ".DBBBD.",
    "..DDD..",
])

CLAW_PINCH = prop([
    "H...H",
    "BB.BB",
    ".BBBD",
    ".BBD.",
    "..D..",
])


def lens(eye):
    rows = [
        "..GGGGG.....",
        ".GSSSSSG....",
        "GSSSSSSSG...",
        "GSSSSSSSG...",
        "GSSSSSSSG...",
        "GSSSSSSSG...",
        "GSSSSSSSG...",
        ".GSSSSSGG...",
        "..GGGGGNN...",
        "........NN..",
        ".........NN.",
        "..........NN",
    ]
    if eye == "open":
        rows[2] = "GSSWEESSG..."
        rows[3] = "GSSEEEESG..."
        rows[4] = "GSSEEEESG..."
        rows[5] = "GSSEEEESG..."
        rows[6] = "GSSSEESSG..."
    elif eye == "closed":
        rows[4] = "GSEEEEESG..."
    return prop(rows)


def glasses(dy=0, shift=0):
    c = Canvas(FRAME, FRAME)
    ring = ["..KKK..", ".K...K.", "K.....K", "K.....K", "K.....K", ".K...K.", "..KKK.."][1:6]
    ring = [".KKK.", "K...K", "K...K", "K...K", "K...K", ".KKK."]
    top = 38 + dy
    for ex in (23 + shift, 36 + shift):
        c.rows(ex, top + 3, ring)
    c.rect(28 + shift, top + 5, 35 + shift, top + 5, "K")
    return c


HARD_HAT = prop([
    ".....YYYYYY.....",
    "...YYYYYyYYYY...",
    "..YYYYYYyYYYYY..",
    "..YYYYYYyYYYYY..",
    "yyyyyyyyyyyyyyyy",
])

PITH_HELMET = prop([
    ".....cccccc.....",
    "...cccccccccc...",
    "..cccccccccccc..",
    "..CCCCCCCCCCCC..",
    "cccccccccccccccc",
])

BOW_TIE = prop(["KK...KK", "KKKKKKK", "KK...KK"])

CLAW_UP = prop([
    "H...H.",
    "BB.BB.",
    "BB.BB.",
    "BBBBB.",
    ".BBBD.",
    ".BBD..",
    ".DBD..",
])

ALERT = prop([
    ".WWWWW.",
    "WWWRWWW",
    "WWWRWWW",
    "WWWRWWW",
    "WWWWWWW",
    "WWWRWWW",
    ".WWWWW.",
    "...WW..",
    "...W...",
])


def limbs(segments, dy=0, dx=0):
    c = Canvas(FRAME, FRAME)
    for (x0, y0), (x1, y1) in segments:
        vertical = abs(y1 - y0) >= abs(x1 - x0)
        ox, oy = (1, 0) if vertical else (0, 1)
        c.line(x0, y0, x1, y1, "B")
        c.line(x0 + ox, y0 + oy, x1 + ox, y1 + oy, "D")
    c.outline()
    for y in range(38 + dy, 54 + dy):
        for x in range(18 + dx, 46 + dx):
            c.px(x, y, ".")
    return c


def claw_up(hx, hy, left=False):
    return (CLAW_UP.mirrored(), hx - 4, hy - 7) if left else (CLAW_UP, hx - 3, hy - 7)


def alert(dy=0, bubble=True, tilt=0, dx=0, sides=("left", "right")):
    segments, claws = [], []
    if "left" in sides:
        hx, hy = 12 + dx - 3 * tilt, 34 + dy
        segments.append(((17 + dx, 45 + dy), (hx, hy)))
        claws.append(claw_up(hx, hy, True))
    if "right" in sides:
        hx, hy = 51 + dx + 3 * tilt, 34 + dy
        segments.append(((46 + dx, 45 + dy), (hx, hy)))
        claws.append(claw_up(hx, hy))
    extras = [(limbs(segments, dy, dx), 0, 0)] + claws
    if bubble:
        extras.append((ALERT, 27 + dx, 15 + dy))
    return extras


NOTE = prop(["..WW", "..W.", "..W.", "WWW.", "WWW."])

CLAW_SIDE = prop([
    "HBBB.",
    "BB...",
    "BB...",
    "BBBD.",
])

CLAW_DOWN = prop([
    "HBBD",
    "BBBD",
    "B..D",
])


def laptop_side(lid="open"):
    c = Canvas(13, 10)
    lids = {
        "open": [(11, 0), (11, 1), (10, 2), (10, 3), (10, 4), (9, 5), (9, 6), (9, 7)],
        "half": [(4, 5), (6, 6), (8, 7)],
        "closed": [],
    }
    for x, y in lids[lid]:
        if lid == "half":
            c.rect(x, y, x + 2, y, "G")
        else:
            c.px(x, y, "S")
            c.px(x + 1, y, "K")
    c.rect(0, 8, 8, 8, "g" if lid != "closed" else "G")
    c.rect(9, 8, 10, 8, "S" if lid == "open" else "G")
    c.rect(0, 9, 11, 9, "G")
    return c.outline()


def crt_side(state="on"):
    c = Canvas(13, 13)
    widths = [8, 10, 11, 12, 12, 12, 11, 10, 8]
    for y, width in enumerate(widths):
        c.rect(0, y, width - 1, y, "c")
        c.px(width - 1, y, "C")
    for y in (3, 5):
        c.rect(5, y, 9, y, "C")
    glow = {"on": "V", "flash": "W", "off": "K"}[state]
    c.rect(0, 1, 0, 7, glow)
    c.rect(3, 9, 6, 10, "C")
    c.rect(1, 11, 8, 11, "C")
    return c.outline()


KEYBOARD_SIDE = prop(["GgGgGgG", "KKKKKKK"])


def tile(chars, color):
    glyphs = {
        "<": ["..X", ".X.", "X..", ".X.", "..X"],
        "/": ["..X", "..X", ".X.", "X..", "X.."],
        ">": ["X..", ".X.", "..X", ".X.", "X.."],
        "_": ["...", "...", "...", "...", "XXX"],
        "$": [".XX", "XX.", ".X.", ".XX", "XX."],
    }
    width = len(chars) * 4 + 1
    rows = ["K" * width]
    for r in range(5):
        row = "K"
        for char in chars:
            row += glyphs[char][r].replace(".", "K").replace("X", color) + "K"
        rows.append(row)
    rows.append("K" * width)
    return prop(rows)


CODE_TILE = tile("</>", "S")
SHELL_TILE = tile(">_", "V")


LAND = [
    "..VVV.....VV.......VVVV...",
    ".VVVVV...VVVV.....VVVVVV..",
    "..VVVV....VVVV.....VVVV...",
    "...VV......VVV......VV....",
    "....V.......V.......V.....",
]


def desk_globe(phase):
    c = Canvas(15, 17)
    for y in range(11):
        for x in range(11):
            if (x - 5) ** 2 + (y - 5) ** 2 <= 27:
                band = LAND[(y - 2) % len(LAND)] if 1 <= y <= 9 else "." * 26
                land = band[(x + phase * 3) % len(band)] == "V"
                c.px(x + 1, y + 1, "V" if land else "b")
    for x, y in ((3, 3), (4, 2), (3, 4)):
        c.px(x, y, "S")
    for x, y in ((6, 0), (9, 0), (11, 1), (12, 3), (13, 5), (13, 7), (12, 9), (11, 11), (9, 12)):
        c.px(x, y, "Y")
    c.rect(6, 12, 7, 13, "t")
    c.rect(3, 14, 10, 15, "t")
    c.rect(3, 15, 10, 15, "N")
    return c.outline()


def mini(step):
    legs = ".D.D.D.D." if step else "D.D.D.D.."
    return prop([".BBBBBBB.", "BBEBBBEBB", "BBBBBBBBB", ".BBBBBBB.", legs])


def baton(c, x0, y0, x1, y1):
    c.line(x0, y0, x1, y1, "W")
    c.px(x0, y0, "N")


def conductor(position, dy=0):
    hx, hy = {"left": (44, 34), "up": (49, 31), "right": (53, 34)}[position]
    tx, ty = {"left": (-7, -5), "up": (2, -9), "right": (7, -5)}[position]
    hy += dy
    stick = Canvas(FRAME, FRAME)
    baton(stick, hx, hy - 6, hx + tx, hy - 6 + ty)
    c = Canvas(FRAME, FRAME)
    c.paste(limbs([((46, 45 + dy), (hx, hy))], dy), 0, 0)
    c.paste(stick.outline(), 0, 0)
    item, x, y = claw_up(hx, hy)
    c.paste(item, x, y)
    return c


def sofa():
    c = Canvas(FRAME, FRAME)
    c.rect(8, 33, 55, 46, "P")
    c.rect(9, 33, 54, 33, "Q")
    c.px(8, 33, ".")
    c.px(55, 33, ".")
    c.rect(8, 46, 55, 46, "p")
    for x0 in (3, 52):
        c.rect(x0, 40, x0 + 8, 55, "P")
        c.rect(x0 + 1, 40, x0 + 7, 40, "Q")
        c.px(x0, 40, ".")
        c.px(x0 + 8, 40, ".")
    c.rect(3, 41, 3, 55, "Q")
    c.rect(11, 41, 11, 55, "p")
    c.rect(60, 41, 60, 55, "p")
    c.rect(12, 47, 51, 47, "Q")
    c.rect(12, 48, 51, 50, "P")
    c.rect(12, 51, 51, 55, "p")
    c.rect(31, 48, 32, 50, "p")
    for x in (5, 57):
        c.rect(x, 56, x + 1, 58, "N")
    return c.outline()


SOFA = sofa()

PAGES = {
    "a": dict(headline=(1, 12), photo=(17, 23), lines=((1, 12), (1, 9), (1, 12), (1, 7)), right=((25, 28), (25, 27), (17, 28), (17, 25))),
    "b": dict(headline=(17, 28), photo=(1, 7), lines=((17, 28), (17, 26), (17, 28), (17, 22)), right=((9, 12), (9, 11), (1, 12), (1, 10))),
}


def newspaper(page="a", turn=0):
    c = Canvas(32, 14)
    layout = PAGES[page]
    right = 29 if turn == 0 else 23 if turn == 1 else 15
    c.rect(1, 1, right + 1, 12, "c")
    x0, x1 = layout["headline"]
    c.rect(x0 + 1, 2, x1 + 1, 3, "K")
    p0, p1 = layout["photo"]
    c.rect(p0 + 1, 5 - 3 * (p0 > 14), p1 + 1, 9 - 3 * (p0 > 14), "b")
    for row, (a, b) in zip((5, 7, 9, 11), layout["lines"]):
        if not (p0 <= a <= p1):
            c.rect(a + 1, row, b + 1, row, "G")
    for row, (a, b) in zip((2, 4, 9, 11), layout["right"]):
        c.rect(a + 1, row, b + 1, row, "G")
    c.rect(15, 1, 16, 12, "C")
    if turn:
        c.rect(right + 2, 0, 31, 13, ".")
        c.rect(17, 1, right + 1, 12, "C")
        if turn == 2:
            c.rect(15, 0, 17, 13, ".")
            c.rect(15, 0, 16, 12, "c")
            c.rect(17, 0, 17, 12, "C")
    return c.outline()


FOLDED = prop([
    "cccccccccc",
    "cKKKKccGGc",
    "cccccccccc",
    "CCCCCCCCCC",
])

CLAW_HOLD = prop([
    ".HB.",
    "BBBB",
    "BB..",
    "BBBB",
    ".DD.",
])


def reading(eyes="open", page="a", turn=0, sink=0):
    body = crab(dy=sink, lifts=(-3 + sink,) * 4, eyes=eyes, arms=("none", "none"))
    edge = (29, 23, 15)[turn]
    extras = [
        (newspaper(page, turn), 16, 40 + sink),
        (CLAW_HOLD, 13, 43 + sink),
        (CLAW_HOLD.mirrored(), 45 - 29 + edge, 43 + sink - 4 * (turn == 2)),
    ]
    return frame(body, extras, [(SOFA, 0, 0)], dy=-6)


def jab(reach, hit=False):
    c = Canvas(FRAME, FRAME)
    end = 46 + reach
    c.rect(46, 46, end, 47, "D")
    c.rect(46, 46, end, 46, "B")
    claw = [
        "..BBBH",
        ".BBBBB",
        "BBBB..",
        ".BBBBD",
        "..DDD.",
    ] if hit else [
        "..BBH.",
        ".BB...",
        "BBB...",
        ".BB...",
        "..BDD.",
    ]
    c.rows(end, 44, claw)
    c.outline()
    if hit:
        for x0, y0, x1, y1 in ((end + 7, 42, end + 9, 40), (end + 8, 46, end + 11, 46), (end + 7, 50, end + 9, 52)):
            c.line(x0, y0, x1, y1, "Y")
    return c


def jab_down(hit=False):
    c = Canvas(FRAME, FRAME)
    tip = 58 if hit else 55
    c.rect(46, 46, 48, 47, "D")
    c.rect(47, 46, 48, tip - 5, "D")
    c.rows(45, tip - 4, [
        "HBBBD",
        "BBBBD",
        ".BBD.",
        ".BBD.",
        "..D..",
    ] if hit else [
        "HBBBD",
        "BBBBD",
        "BB.BD",
        "B...D",
        "B...D",
    ])
    c.outline()
    if hit:
        for x0, y0, x1, y1 in ((43, 58, 41, 56), (51, 58, 53, 56)):
            c.line(x0, y0, x1, y1, "Y")
    return c


def jab_up(top, hit=False):
    c = Canvas(FRAME, FRAME)
    tip = top - (11 if hit else 7)
    c.rect(43, tip + 5, 44, top + 1, "B")
    c.rows(41, tip, [
        "..H..",
        ".HBD.",
        ".BBD.",
        "HBBBD",
        "BBBBD",
    ] if hit else [
        "H...D",
        "B...D",
        "BB.BD",
        "HBBBD",
        "BBBBD",
    ])
    c.outline()
    if hit:
        for x0, y0, x1, y1 in ((40, tip - 1, 38, tip - 3), (43, tip - 2, 43, tip - 4), (46, tip - 1, 48, tip - 3)):
            c.line(x0, y0, x1, y1, "Y")
    return c


def sprite(rows, outline=True):
    return prop(rows, outline)


NIGHTCAP = sprite([
    "...............WWW",
    "..............WWWW",
    "...........bbbbWW.",
    "........bbbbbb....",
    ".....bbbbbbbb.....",
    "...bbbbbbbbbb.....",
    ".bbbbbbbbbbbbb....",
    "WWWWWWWWWWWWWWWW..",
    "WWWWWWWWWWWWWWWW..",
])

NIGHTCAP_SWAY = sprite([
    "................WWW",
    "...............WWWW",
    "...........bbbbbWW.",
    "........bbbbbb.....",
    ".....bbbbbbbb......",
    "...bbbbbbbbbb......",
    ".bbbbbbbbbbbbb.....",
    "WWWWWWWWWWWWWWWW...",
    "WWWWWWWWWWWWWWWW...",
])

SWEAT = sprite([".S.", "SWS", "SSS", ".S."])


def fan(phase):
    c = Canvas(FRAME, FRAME)
    cx, cy = 54, 41
    for y in range(-7, 8):
        for x in range(-6, 7):
            inside = (x / 6.5) ** 2 + (y / 7.5) ** 2
            if inside <= 1:
                c.px(cx + x, cy + y, "G" if inside > 0.7 else "K")
    spokes = ((0, -5), (0, 5), (-4, 0), (4, 0)) if phase % 2 == 0 else ((-3, -4), (3, 4), (-3, 4), (3, -4))
    for dx, dy in spokes:
        c.line(cx, cy, cx + dx, cy + dy, "g")
    c.rect(cx - 1, cy - 1, cx + 1, cy + 1, "W")
    c.rect(cx, cy + 8, cx, 56, "G")
    c.rect(cx - 4, 57, cx + 4, 58, "K")
    c.rect(cx - 3, 57, cx + 3, 57, "G")
    c.outline()
    for y, length in ((39, 3), (47, 4), (50, 3)):
        start = 46 - (phase * 2 + y) % 5
        c.line(start - length, y, start, y, "W")
    return c


MOUTH = glyph([".EE.", "EEEE", "ERRE", ".EE."])


def battery(level, color):
    rows = ["WWWWWWWWWW.", "WKKKKKKKKWW", "WKKKKKKKKWW", "WKKKKKKKKWW", "WWWWWWWWWW."]
    rows = [list(row) for row in rows]
    for i in range(level):
        for y in (1, 2, 3):
            rows[y][1 + i * 2] = color
            rows[y][2 + i * 2] = color
    return prop(["".join(row) for row in rows])


BOLT = sprite(["..YY", ".YY.", "YYYY", ".YY.", "YY.."])


def umbrella(top=14, dy=0, cx=33, radius=16):
    c = Canvas(FRAME, FRAME)
    for y in range(radius + 1):
        for x in range(-radius, radius + 1):
            if x * x + (radius - y) ** 2 <= radius * radius:
                stripe = (x + radius) // 6 % 2
                c.px(cx + x, top + y, "W" if stripe else "R")
    for x in range(-radius, radius + 1, 6):
        for dx in range(1, 5):
            if -radius < x + dx < radius:
                c.px(cx + x + dx, top + radius, ".")
    c.rect(cx, top - 2, cx, top - 1, "K")
    c.rect(cx, top + radius, cx, 36 + dy, "K")
    c.outline()
    c.paste(limbs([((46, 45 + dy), (49, 39 + dy)), ((49, 39 + dy), (cx + 5, 33 + dy))], dy), 0, 0)
    c.paste(CLAW_SIDE.mirrored(), cx, 31 + dy)
    return c


def rain(phase):
    c = Canvas(FRAME, FRAME)
    for x, y in ((4, 8), (12, 20), (7, 34), (58, 30), (61, 14), (10, 46), (55, 6), (2, 26), (60, 44), (16, 2)):
        yy = (y + phase * 5) % 52
        if yy < 56:
            c.rect(x, yy, x, yy + 2, "S")
    if phase % 2 == 0:
        c.rows(5, 57, ["S...S", ".S.S."])
    else:
        c.rows(56, 57, ["S...S", ".S.S."])
    return c


SHADES = glyph([
    "KKKKKKK......KKKKKKK",
    "KKKKKKKKKKKKKKKKKKKK",
    "KKKKKKK......KKKKKKK",
    ".KKKKK........KKKKK.",
])


def shades(glint):
    c = glyph(SHADES.lines())
    c.px(1 + glint, 0 if glint < 3 else 1, "W")
    c.px(14 + glint, 0 if glint < 3 else 1, "W")
    return c


def sun(phase):
    c = Canvas(17, 17)
    for y in range(17):
        for x in range(17):
            if (x - 8) ** 2 + (y - 8) ** 2 <= 16:
                c.px(x, y, "Y")
    rays = [((8, 0), (8, 2)), ((8, 14), (8, 16)), ((0, 8), (2, 8)), ((14, 8), (16, 8))] if phase == 0 else [
        ((2, 2), (3, 3)), ((14, 2), (13, 3)), ((2, 14), (3, 13)), ((14, 14), (13, 13))]
    for (x0, y0), (x1, y1) in rays:
        c.line(x0, y0, x1, y1, "Y")
    c.rect(6, 6, 7, 6, "W")
    return c.outline("y")


DRINK = sprite([
    "R....",
    ".R...",
    "SSSSS",
    "SWSSS",
    ".SSS.",
    "..K..",
    ".KKK.",
])

BOBBLE_HAT = sprite([
    ".......WW.......",
    "......WWWW......",
    ".....RRRRRR.....",
    "...RRRRRRRRRR...",
    "..RRWRRWRRWRRR..",
    "..RRRRRRRRRRRR..",
    "..WWWWWWWWWWWW..",
])

SCARF = sprite([
    "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRR",
    "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
    "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRR",
    ".....................RRRR.....",
    ".....................WWWW.....",
    ".....................RRRR.....",
    ".....................R.R.R....",
])


def snowfall(phase):
    c = Canvas(FRAME, FRAME)
    for x, y in ((5, 6), (14, 22), (9, 38), (56, 12), (60, 30), (51, 2), (3, 48), (59, 46), (22, 10), (44, 18)):
        yy = (y + phase * 3) % 56
        c.rows(x - 1, yy - 1, [".W.", "WWW", ".W."] if (x + phase) % 3 else ["W.W", ".W.", "W.W"])
    c.rect(2, 58, 13, 58, "W")
    c.rect(50, 58, 61, 58, "W")
    return c


PACKET = sprite([
    "TTTNTTT",
    "TTTNTTT",
    "NNNNNNN",
    "tttNttt",
    "tttNttt",
])

ARROW_DOWN = sprite([".VVV.", ".VVV.", ".VVV.", "VVVVV", ".VVV.", "..V.."])
ARROW_UP = sprite(["..S..", ".SSS.", "SSSSS", ".SSS.", ".SSS.", ".SSS."])

RAM = sprite([
    "VKVKVKVKV",
    "VVVVVVVVV",
    "YYYYYYYYY",
])


CATCH = {0: "left", 4: "right"}
JUGGLE_PATH = [(11, 26), (12, 14), (26, 7), (40, 14), (42, 26), (26, 30)]


def juggle(phase):
    spots = [(phase + offset) % len(JUGGLE_PATH) for offset in (0, 2, 4)]
    left = 2 if 0 in spots else 0
    right = 2 if 4 in spots else 0
    extras = raised(left, right)
    for spot in spots:
        x, y = JUGGLE_PATH[spot]
        extras.append((RAM, x, y + (left if spot == 0 else right if spot == 4 else 0)))
    return extras


def raised(left=0, right=0):
    return [(CLAW_UP.mirrored(), 12, 27 + left), (CLAW_UP, 44, 27 + right)]


def holding(y, grip=True, dy=0):
    lx, rx = (23, 35) if grip else (18, 41)
    hy = y + dy
    arms = limbs([((17, 45 + dy), (lx, hy + 1)), ((46, 45 + dy), (rx + 5, hy + 1))], dy)
    return [(arms, 0, 0), (CLAW_SIDE, lx - 1, hy - 2), (CLAW_SIDE.mirrored(), rx - 1, hy - 2)]


def browser(progress):
    width = 19
    rows = [["W"] * width for _ in range(13)]
    for x in range(width):
        rows[0][x] = "G"
        rows[1][x] = "G"
        rows[2][x] = "G"
    for x, color in ((1, "R"), (3, "Y"), (5, "V")):
        rows[0][x] = color
    for x in range(1, width - 1):
        rows[1][x] = "b" if x <= 1 + progress * 2 else "W"
    for x in range(2, 11):
        rows[4][x] = "K"
    for x in range(2, 9):
        rows[6][x] = "b"
    for x in range(10, 17):
        rows[6][x] = "g"
    for x in range(2, 15):
        rows[8][x] = "g"
    for y in range(10, 12):
        for x in range(2, 7):
            rows[y][x] = "S"
    for x in range(9, 17):
        rows[10][x] = "g"
    return prop(["".join(row) for row in rows])


def flipped(item):
    other = Canvas(item.width, item.height)
    other.grid = item.grid[::-1]
    return other


def scratch(phase):
    hx = 43 + phase
    arm = limbs([((46, 45), (51, 40)), ((51, 40), (hx + 5, 35))])
    return [(arm, 0, 0), (CLAW_SIDE.mirrored(), hx, 32 + phase)]


MUG = sprite([
    "WNNNNW..",
    "WWWWWWWW",
    "WWWWWW.W",
    "WWWWWWWW",
    "WWWWWW..",
    ".WWWW...",
])


def steam(x, y, phase):
    c = Canvas(FRAME, FRAME)
    for i, (dx, dy) in enumerate(((0, 0), (1, -2), (0, -4), (1, -6))):
        if (i + phase) % 3:
            c.px(x + dx + (phase % 2), y + dy, "g")
            c.px(x + dx + 2 - (phase % 2), y + dy - 1, "g")
    return c


def coffee(sip=False, phase=0):
    if sip:
        return [(MUG, 29, 45), (CLAW_SIDE.mirrored(), 37, 46), (steam(31, 42, phase), 0, 0)]
    return [(MUG, 43, 43), (CLAW_SIDE.mirrored(), 51, 44), (steam(45, 40, phase), 0, 0)]


HEART = sprite([".RR.RR.", "RRRRRRR", ".RRRRR.", "..RRR..", "...R..."])


def headphones(dy=0):
    c = Canvas(FRAME, FRAME)
    top = 33 + dy
    c.rect(20, top, 43, top, "K")
    c.line(16, top + 4, 19, top + 1, "K")
    c.line(47, top + 4, 44, top + 1, "K")
    c.rect(16, top + 4, 16, top + 6, "K")
    c.rect(47, top + 4, 47, top + 6, "K")
    for x0 in (13, 46):
        c.rect(x0, top + 7, x0 + 4, top + 13, "K")
        c.rect(x0 + 1, top + 8, x0 + 3, top + 12, "b")
        c.rect(x0 + 1, top + 8, x0 + 3, top + 8, "S")
    return c.outline()


BUBBLES = {
    1: glyph([".S.", "S.S", ".S."]),
    2: glyph([".SSS.", "SW..S", "S...S", "S...S", ".SSS."]),
    3: glyph(["..SSS..", ".S...S.", "SW....S", "S.....S", "S.....S", ".S...S.", "..SSS.."]),
    0: glyph(["S...S", "..W..", ".W.W.", "..W..", "S...S"]),
}


def wand(raised=False):
    c = Canvas(FRAME, FRAME)
    if raised:
        c.rows(31, 45, [".SSS.", "S...S", "S...S", "S...S", ".SSS."])
        c.line(36, 47, 45, 49, "N")
        c.outline()
        c.paste(CLAW_SIDE.mirrored(), 45, 46)
    else:
        c.rows(46, 33, [".SSS.", "S...S", "S...S", "S...S", ".SSS."])
        c.line(48, 38, 48, 45, "N")
        c.outline()
        c.paste(CLAW_PINCH, 45, 44)
    return c


BUBBLE_PATHS = [
    [(2, 30, 37), (2, 26, 30), (3, 21, 22), (3, 17, 14), (0, 16, 8)],
    [(1, 34, 40), (2, 38, 33), (2, 43, 26), (2, 47, 18), (0, 50, 12)],
    [(1, 31, 41), (1, 30, 34), (2, 32, 27), (0, 31, 21)],
]


def bubbles(step):
    c = Canvas(FRAME, FRAME)
    for index, path in enumerate(BUBBLE_PATHS):
        t = step - index * 2
        if 0 <= t < len(path):
            size, x, y = path[t]
            c.rows(x, y, BUBBLES[size].lines())
    return c


MANIA_CHART = [(0, (0,)), (1, (2,)), (2, (1,)), (3, (3,)), (4, (0, 2)), (5, (1,)), (6, (3,)), (7, (2,))]


def mania_tile(step):
    width, height, hit = 17, 18, 15
    rows = [["K"] * width for _ in range(height)]
    for y in range(height):
        for lane in range(5):
            rows[y][lane * 4] = "G" if lane in (0, 4) else "E"
    pressed = set()
    for beat, lanes in MANIA_CHART:
        distance = (beat - step) % len(MANIA_CHART)
        y = hit - distance * 2
        for lane in lanes:
            if distance == 0:
                pressed.add(lane)
            if 1 <= y < height - 1:
                for dx in range(3):
                    rows[y][lane * 4 + 1 + dx] = "W" if lane in (0, 3) else "F"
    for lane in range(4):
        for dx in range(3):
            rows[hit + 1][lane * 4 + 1 + dx] = "W" if lane in pressed else "g"
    return prop(["".join(row) for row in rows]), pressed


def mania(step):
    tile, pressed = mania_tile(step)
    pad = Canvas(FRAME, FRAME)
    pad.rect(20, 56, 43, 58, "K")
    for lane in range(4):
        x = 21 + lane * 6
        pad.rect(x, 55, x + 4, 56, "F" if lane in pressed else "g")
    pad.outline()
    extras = [(pad, 0, 0), (tile, 22, 9)]
    left = 21 if 0 in pressed else 27 if 1 in pressed else 24
    right = 39 if 3 in pressed else 33 if 2 in pressed else 36
    extras.append((CLAW_TAP, left - 1, 47 + 2 * (0 in pressed or 1 in pressed)))
    extras.append((CLAW_TAP, right - 1, 47 + 2 * (2 in pressed or 3 in pressed)))
    return extras


CLAW_TAP = prop([
    "HBBBD",
    "BBBBD",
    ".BBD.",
    ".BBD.",
    "..D..",
])


FLOOR = 59


def ground(item, x):
    return (item, x, FLOOR + 1 - item.height)


def frame(body, extras=(), behind=(), dx=0, dy=0):
    c = Canvas(FRAME, FRAME)
    for item, x, y in behind:
        c.paste(item, x, y)
    c.paste(body, ORIGIN[0] + dx, ORIGIN[1] + dy)
    for item, x, y in extras:
        c.paste(item, x, y)
    return c.lines()


SLEEP = dict(dy=5, lifts=(9, 9, 9, 9), eyes="closed")
AIR = dict(dy=-3)
HANG = dict(lifts=(-3, -3, -3, -3))
GOOGLY = [("up", "down"), ("left", "right"), ("down", "up"), ("right", "left")]
STAR = sprite([
    "...Y...",
    "..YYY..",
    "YYYWYYY",
    ".YYYYY.",
    "..YYY..",
    ".YY.YY.",
    ".Y...Y.",
])
STAR_FAR = sprite([
    "..y..",
    ".yYy.",
    "yYYYy",
    ".yYy.",
    ".y.y.",
])


def stars(phase, cy=29, count=8, rx=15, ry=4):
    front, back = [], []
    for k in range(3):
        angle = 2 * math.pi * (phase / count + k / 3)
        x, y = 32 + rx * math.cos(angle), cy + ry * math.sin(angle)
        near = math.sin(angle) >= 0
        trail = Canvas(FRAME, FRAME)
        trail.px(round(32 + rx * math.cos(angle - 0.55)), round(cy + ry * math.sin(angle - 0.55)), "Y" if near else "y")
        layer = front if near else back
        layer.append((trail, 0, 0))
        layer.append((STAR, round(x) - 4, round(y) - 4) if near else (STAR_FAR, round(x) - 3, round(y) - 3))
    return front, back


def starry(body, phase, dx=0, extras=()):
    front, back = stars(phase)
    return frame(body, list(extras) + front, back, dx=dx)


def pancake(stunned=None):
    c = Canvas(FRAME, FRAME)
    c.rect(13, 50, 50, 58, "B")
    for x, y in ((13, 50), (50, 50), (13, 58), (50, 58)):
        c.px(x, y, ".")
    c.rect(14, 50, 49, 50, "H")
    c.rect(13, 51, 13, 57, "H")
    c.rect(14, 58, 49, 58, "D")
    c.rect(50, 51, 50, 57, "D")
    for ex in (24, 37):
        for dx, dy in ((0, 0), (2, 0), (1, 1), (0, 2), (2, 2)):
            c.px(ex + dx, 52 + dy, "E")
    c.rows(6, 55, CLAW_SIDE.mirrored().lines()[1:-1])
    c.rows(52, 55, CLAW_SIDE.lines()[1:-1])
    c.rect(10, 52, 12, 53, "D")
    c.rect(51, 52, 53, 53, "D")
    c.outline()
    for item, x, y in stunned or []:
        c.paste(item, x, y)
    return c.lines()


def squashed(width, eyes="squint", impact=False, speed=0, dust=0, brace=False):
    height = 448 // width
    right = 48
    top = 53 - height + 1 + (16 - height) // 3
    left, bottom = right - width + 1, top + height - 1
    c = Canvas(FRAME, FRAME)
    c.rect(left, top, right, bottom, "B")
    for x, y in ((left, top), (left, bottom)):
        c.px(x, y, ".")
    c.rect(left + 1, top, right, top, "H")
    c.rect(left, top + 1, left, bottom - 1, "H")
    c.rect(left + 1, bottom, right, bottom, "D")
    c.rect(right, top + 1, right, bottom - 1, "D")
    middle = left + width // 2
    eye(c, middle - 5, top - 1 + height // 4, eyes, True)
    eye(c, middle + 2, top - 1 + height // 4, eyes, False)
    for index, lx in enumerate((left + 3, left + 8, left + 13, left + 18)):
        if lx + 1 < right:
            drift = 3 - index
            c.line(lx, bottom + 1, lx - drift, bottom + 4, "D")
            c.line(lx + 1, bottom + 1, lx + 1 - drift, bottom + 4, "D")
            c.px(lx - drift, bottom + 4, "M")
    c.outline()
    upper = (left - 1, top + 4)
    lower = (left - 1, top + height - 6)
    segments = [(upper, (upper[0] - 5, upper[1] - 6))]
    claws = [claw_up(upper[0] - 5, upper[1] - 6, True)]
    if brace:
        segments.append(((right - 2, top - 1), (right - 2, top - 6)))
        claws.append(claw_up(right - 3, top - 6))
    else:
        segments.append((lower, (lower[0] - 6, lower[1] + 1)))
        claws.append((CLAW_SIDE.mirrored(), lower[0] - 11, lower[1] - 2))
    c.paste(limbs(segments, 99, 99), 0, 0)
    for item, x, y in claws:
        c.paste(item, x, y)
    if impact:
        for x0, y0, x1, y1 in ((47, top - 3, 43, top - 7), (48, top - 4, 48, top - 9), (47, bottom + 3, 43, bottom + 7), (48, bottom + 4, 48, bottom + 8)):
            c.line(x0, y0, x1, y1, "Y")
    for index in range(speed):
        x = left + 4 + index * 5
        length = 2 + speed * 2 - index
        c.rect(x, top - 10 - length, x, top - 10, "g")
    for dx, dy in ((0, 0), (-2, -3), (1, -5))[:dust]:
        c.px(right - 1 + dx, top - 13 + dy, "W")
        c.px(right - 2 + dx, top - 12 + dy, "g")
    return c.lines()


def climbing(step):
    reach = step < 2
    dy = step % 2
    c = Canvas(FRAME, FRAME)
    left, right, top, bottom = 33, 46, 38 + dy, 54 + dy
    feet = ((44, 49, 52), (46, 50, 53)) if reach else ((45, 50, 52), (43, 48, 53))
    for index, y in enumerate((top + 4, top + 8, top + 11, top + 15)):
        bend = (index + step) % 2
        c.rect(right + 1, y - bend, right + 2, y - bend, "D")
        c.rect(right + 3 - 0, y - bend - 1 + bend, right + 3, y - bend + 1, "M")
    c.rect(left, top, right, bottom, "B")
    for x, y in ((left, top), (right, top), (left, bottom), (right, bottom)):
        c.px(x, y, ".")
    c.rect(left + 1, top, right - 1, top, "H")
    c.rect(left, top + 1, left, bottom - 1, "H")
    c.rect(left + 1, bottom, right - 1, bottom, "D")
    c.rect(right, top + 1, right, bottom - 1, "D")
    c.rect(left + 2, top + 2, left + 2, bottom - 3, "H")
    c.rect(right - 4, top + 3, right - 2, top + 6, "E")
    c.px(right - 4, top + 3, "W")
    c.outline()
    near, far = (top - 12, top - 4) if reach else (top - 4, top - 12)
    c.paste(wall_arm(far, top, True), 0, 0)
    c.paste(wall_arm(near, top, False), 0, 0)
    return c.lines()


def shaded(item):
    other = Canvas(item.width, item.height)
    swap = {"H": "B", "B": "D", "D": "M"}
    other.grid = [[swap.get(color, color) for color in row] for row in item.grid]
    return other


def wall_arm(y, top, back):
    c = Canvas(FRAME, FRAME)
    x = 41 if back else 43
    c.rect(x, y + 5, x + 2, top + 1, "B")
    c.rect(x + 2, y + 5, x + 2, top + 1, "D")
    c.rows(44, y, [
        "..BBBH",
        ".BB...",
        "BB....",
        "BBB...",
        ".BBBBD",
    ])
    c.outline()
    for yy in range(top + 1, top + 4):
        for xx in range(33, 47):
            c.px(xx, yy, ".")
    for yy in range(FRAME):
        c.px(50, yy, ".")
    return shaded(c) if back else c


ROPE_TOP = (32, 27)
GRIP_ROW = 27
THROW_HAND = (48, 16)


def rope(top, bottom):
    c = Canvas(FRAME, FRAME)
    c.rect(ROPE_TOP[0], top, ROPE_TOP[0], bottom, "t")
    return c.outline()


def arms_up(xs, top, dy=0):
    c = Canvas(FRAME, FRAME)
    for x in xs:
        c.rect(x, top, x + 2, 38 + dy, "B")
        c.rect(x + 2, top, x + 2, 38 + dy, "D")
    c.outline()
    for y in range(38 + dy, 54 + dy):
        for x in range(18, 46):
            c.px(x, y, ".")
    return c


def hanging(swing):
    body = crab(lifts=(-3, -2, -3, -2) if swing else (-2, -3, -2, -3), eyes="up", arms=("none", "none"))
    return frame(body, [(rope(ROPE_TOP[1], 37), 0, 0), (arms_up((26, 35), 32), 0, 0), (CLAW_SIDE, 26, ROPE_TOP[1]), (CLAW_SIDE.mirrored(), 32, ROPE_TOP[1])])


def throwing(wind):
    if wind:
        arm = limbs([((46, 45), (51, 50))])
        return frame(crab(dy=1, eyes="up", arms=(0, "none")), [(arm, 0, 0), (CLAW_DOWN, 49, 50)])
    arm = limbs([((46, 45), (48, 23))])
    return frame(crab(eyes="up", arms=(0, "none")), [(arm, 0, 0), claw_up(48, 23)])


def hook():
    c = Canvas(FRAME, FRAME)
    c.rows(28, 26, [
        "..GgggG..",
        ".GG.g.GG.",
        "GG..g..GG",
        "G...g...G",
        "....G....",
        "....G....",
    ])
    return c.outline().lines()


def balloon(radius, glint=True):
    size = radius * 2 + 1
    c = Canvas(size, size + radius // 2 + 1)
    for y in range(size + radius // 2):
        for x in range(size):
            ry = (y - radius) * (0.85 if y > radius else 1)
            if (x - radius) ** 2 + ry ** 2 <= radius * radius + radius:
                c.px(x, y, "R")
    c.px(radius, size + radius // 2, "R")
    if glint and radius >= 3:
        c.rect(radius - radius // 2 - 1, radius - radius // 2 - 1, radius - radius // 2, radius - radius // 2 - 1, "W")
        c.px(radius - radius // 2 - 1, radius - radius // 2, "W")
    return c.outline()


def inflating(radius):
    item = balloon(radius)
    arm = limbs([((46, 45), (49, 44))])
    return frame(crab(eyes="right" if radius < 5 else "squint", arms=(0, "none")),
                 [(item, 51 - radius, 44 - item.height + 2), (arm, 0, 0), (CLAW_HOLD.mirrored(), 47, 42)])


def floating(sway, dy=0, popped=False):
    hx, hy = 47, 30 + dy
    arm = limbs([((46, 45 + dy), (hx, hy))], dy)
    extras = [(arm, 0, 0), claw_up(hx, hy)]
    if popped:
        c = Canvas(FRAME, FRAME)
        for x0, y0, x1, y1 in ((47, 12, 47, 6), (42, 14, 38, 10), (52, 14, 56, 10), (41, 19, 36, 19), (53, 19, 58, 19)):
            c.line(x0, y0, x1, y1, "Y")
        c.rect(46, 18, 48, 20, "W")
        extras.insert(0, (c, 0, 0))
        extras.append((sprite(["RR", ".R"]), 40, 22))
    else:
        item = balloon(5)
        bx = 43 + sway
        extras.insert(0, (item, bx, 2 + dy))
        knot = (bx + 6, 2 + dy + item.height - 1)
        string = Canvas(FRAME, FRAME)
        string.line(knot[0], knot[1], hx + 1, hy - 7, "g")
        extras.insert(0, (string, 0, 0))
    body = crab(dy=dy, lifts=(-3, -2, -3, -2) if sway else (-2, -3, -2, -3), eyes="wide" if popped else "up", arms=(0, "none"))
    return frame(body, extras)


def dangling(step):
    dy = (0, 1, 1, 0)[step % 4]
    eyes = ("down", "down", "left", "open", "right", "down", "closed", "open")[step]
    body = crab(dy=dy, lifts=((-3, -1, -3, -1), (-1, -3, -1, -3))[step % 2], eyes=eyes, arms=("none", "none"))
    claws = [(CLAW_UP.mirrored(), 20, GRIP_ROW - 2), (CLAW_UP, 38, GRIP_ROW - 2)]
    return frame(body, [(arms_up((21, 40), GRIP_ROW + 4, dy), 0, 0)] + claws)


def binoculars(dy=0, glint=0):
    c = Canvas(FRAME, FRAME)
    for bx in (22, 35):
        c.rect(bx, 40 + dy, bx + 6, 47 + dy, "K")
        c.rect(bx + 1, 41 + dy, bx + 5, 45 + dy, "S")
        for x, y in ((bx + 1, 41), (bx + 5, 41), (bx + 1, 45), (bx + 5, 45)):
            c.px(x, y + dy, "K")
        c.px(bx + 2 + glint, 42 + dy, "W")
    c.rect(29, 43 + dy, 34, 44 + dy, "G")
    c.outline()
    c.paste(CLAW_SIDE, 16, 41 + dy)
    c.paste(CLAW_SIDE.mirrored(), 42, 41 + dy)
    return c


def lookout(dx=0, glint=1, lowered=False):
    if lowered:
        return frame(crab(eyes="wide", arms=("none", "none")), [(binoculars(9, glint), dx, 0), (ALERT, 46, 18)])
    return frame(crab(eyes="none", arms=("none", "none")), [(binoculars(0, glint), dx, 0)], dx=dx)


def sitting(eyes="open", swing=0):
    lifts = (-4, -3, -4, -3) if swing else (-3, -4, -3, -4)
    return frame(crab(dy=5, lifts=lifts, eyes=eyes, arms=("down", "down")))


def parachute(dy=0, lifts=(0, 0, 0, 0), eyes="up", sway=0):
    return frame(crab(dy=dy, lifts=lifts, eyes=eyes, arms=(0, "none")), [(umbrella(10 + dy, dy, 33 + sway), 0, 0)])


def teetering(step):
    tilt = 1 if step % 2 == 0 else -1
    lean = 2 + step % 2
    body = crab(lifts=(0, 0, 2, 5), eyes="wide", arms=("none", "none"))
    return frame(body, alert(-1, False, tilt, lean) + [(SWEAT, 14, 36 - step % 2)], dx=lean)



ANIMATIONS = [
    ("stand", [
        (frame(crab()), 900),
        (frame(crab(dy=1)), 700),
    ]),
    ("walk", [
        (frame(crab(lifts=(1, 0, 1, 0))), 110),
        (frame(crab(dy=1)), 110),
        (frame(crab(lifts=(0, 1, 0, 1))), 110),
        (frame(crab(dy=1)), 110),
    ]),
    ("sleep", [
        (frame(crab(**SLEEP), [(Z_SMALL, 46, 30)]), 1100),
        (frame(crab(**SLEEP, arms=(1, 1)), [(Z_SMALL, 46, 30), (Z_LARGE, 50, 22)]), 1100),
    ]),
    ("jump", [
        (frame(crab(**AIR, lifts=(-2, 0, 0, -2), arms=("up", "up"))), 120),
        (frame(crab(**AIR, lifts=(0, -2, -2, 0), arms=("up", "up"))), 120),
    ]),
    ("fall", [
        (frame(crab(**AIR, lifts=(-3, -3, -3, -3), eyes="wide", arms=("up", -2))), 100),
        (frame(crab(**AIR, lifts=(-3, -3, -3, -3), eyes="wide", arms=(-2, "up"))), 100),
    ]),
    ("land", [
        (frame(crab(dy=3, arms=("down", "down"))), 90),
        (frame(crab(dy=1)), 90),
    ]),
    ("grabbed", [
        (frame(crab(**AIR, lifts=(-3, 0, -3, 0), eyes="squint", arms=("up", "up"))), 110),
        (frame(crab(**AIR, lifts=(0, -3, 0, -3), eyes="squint", arms=(-2, -2))), 110),
    ]),
    ("idle_read_in", [
        (frame(crab(eyes="up"), behind=[(SOFA, 0, 0)]), 220),
        (frame(crab(lifts=(4, 2, 2, 4), arms=("up", "up")), behind=[(SOFA, 0, 0)], dy=-10), 120),
        (frame(crab(dy=1, lifts=(-2, -2, -2, -2), arms=("down", "down")), behind=[(SOFA, 0, 0)], dy=-6), 110),
        (frame(crab(lifts=(-3, -3, -3, -3), arms=(0, "none")), [(FOLDED, 42, 47), (CLAW_HOLD.mirrored(), 51, 45)], [(SOFA, 0, 0)], dy=-6), 200),
    ]),
    ("idle_read", [
        (reading("left"), 900),
        (reading("open"), 500),
        (reading("right"), 900),
        (reading("closed"), 120),
        (reading("left", sink=1), 900),
        (reading("right"), 900),
        (reading("open", turn=1), 120),
        (reading("open", turn=2), 120),
        (reading("left", "b"), 900),
        (reading("open", "b"), 500),
        (reading("right", "b", sink=1), 900),
        (reading("wide", "b"), 400),
        (reading("left", "b"), 900),
        (reading("right", "b"), 900),
        (reading("open", "b", turn=1), 120),
        (reading("open", "b", turn=2), 120),
    ]),
    ("idle_read_out", [
        (frame(crab(lifts=(-3, -3, -3, -3), arms=(0, "none")), [(FOLDED, 42, 47), (CLAW_HOLD.mirrored(), 51, 45)], [(SOFA, 0, 0)], dy=-6), 150),
        (frame(crab(lifts=(4, 2, 2, 4), arms=("up", "up")), behind=[(SOFA, 0, 0)], dy=-10), 120),
        (frame(crab(dy=1), behind=[(SOFA, 0, 0)]), 120),
    ]),
    ("poke", [
        (frame(crab(eyes="right", arms=(0, -1)), dx=-1), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(jab(7, True), 0, 0)]), 130),
        (frame(crab(eyes="right", arms=(0, 0))), 110),
        (frame(crab(eyes="right", arms=(0, "none")), [(jab(7, True), 0, 0)]), 130),
        (frame(crab(eyes="right", arms=(0, "none")), [(jab(3), 0, 0)]), 110),
        (frame(crab(dy=1, eyes="squint", arms=(0, 0))), 270),
    ]),
    ("poke_down", [
        (frame(crab(eyes="down", arms=(0, -1))), 150),
        (frame(crab(dy=1, eyes="down", arms=(0, "none")), [(jab_down(True), 0, 0)]), 140),
        (frame(crab(eyes="down", arms=(0, "none")), [(jab_down(), 0, 0)]), 110),
        (frame(crab(dy=1, eyes="down", arms=(0, "none")), [(jab_down(True), 0, 0)]), 140),
        (frame(crab(eyes="down", arms=(0, "none")), [(jab_down(), 0, 0)]), 100),
        (frame(crab(eyes="squint", arms=(0, 0))), 220),
    ]),
    ("poke_up", [
        (frame(crab(dy=2, eyes="up", arms=("down", "down"))), 130),
        (frame(crab(lifts=(4, 2, 2, 4), eyes="up", arms=(0, "none")), [(jab_up(29, True), 0, 0)], dy=-8), 170),
        (frame(crab(lifts=(2, 0, 0, 2), eyes="up", arms=(0, "none")), [(jab_up(34), 0, 0)], dy=-3), 110),
        (frame(crab(dy=2, arms=("down", "down"))), 100),
        (frame(crab(eyes="squint", arms=(0, 0))), 300),
    ]),
    ("fan", [
        (frame(crab(eyes="closed"), [(fan(phase), 0, 0), (SWEAT, 20, 37 + phase // 2)]), 120)
        for phase in range(4)
    ] + [
        (frame(crab(dy=phase % 2, eyes="squint"), [(fan(phase), 0, 0)]), 120)
        for phase in range(4, 10)
    ]),
    ("yawn", [
        (frame(crab(eyes="closed"), [(battery(1, "R"), 26, 20)]), 600),
        (frame(crab(eyes="closed"), []), 300),
        (frame(crab(dy=-1, eyes="closed", arms=("up", "up")), [(MOUTH, 30, 47), (battery(1, "R"), 26, 19)]), 250),
        (frame(crab(dy=-2, eyes="squint", arms=("up", "up")), [(glyph([".EE.", "EEEE", "EEEE", "ERRE", ".EE."]), 30, 46), (battery(1, "R"), 26, 18)]), 700),
        (frame(crab(dy=-1, eyes="closed", arms=("up", "up")), [(MOUTH, 30, 47)]), 250),
        (frame(crab(dy=1, eyes="closed", arms=("down", "down")), [(battery(1, "R"), 26, 21)]), 700),
    ]),
    ("charge", [
        (frame(crab(dy=level % 2, eyes="squint" if level == 4 else "up"), [(battery(level, "V"), 26, 20 + level % 2), (BOLT, 40, 19 + level % 2)]), 260 if level < 4 else 700)
        for level in range(5)
    ]),
    ("umbrella", [
        (frame(crab(dy=phase % 2, eyes="up" if phase < 2 else "open", arms=(0, "none")), [(rain(phase), 0, 0), (umbrella(14 + phase % 2, phase % 2), 0, 0)]), 180)
        for phase in range(6)
    ]),
    ("sunglasses", [
        (frame(crab(dy=1 if phase in (2, 3) else 0, arms=(0, "none")), [(sun(phase % 2), 2, 6), (shades(phase), 22, 42 + (phase in (2, 3))), (DRINK, 47, 42 + (phase in (2, 3))), (CLAW_PINCH, 47, 48 + (phase in (2, 3)))]), 300)
        for phase in range(6)
    ]),
    ("snow", [
        (frame(crab(eyes="squint", arms=(0, 0)), [(snowfall(phase), 0, 0), (BOBBLE_HAT, 23, 31), (SCARF, 16, 46)], dx=(-1, 1)[phase % 2]), 110)
        for phase in range(8)
    ]),
    ("nightcap", [
        (frame(crab(**SLEEP), [(NIGHTCAP, 19, 35), (Z_SMALL, 46, 30)]), 1100),
        (frame(crab(**SLEEP, arms=(1, 1)), [(NIGHTCAP_SWAY, 19, 35), (Z_SMALL, 46, 30), (Z_LARGE, 50, 22)]), 1100),
    ]),
    ("packets", [
        (frame(crab(eyes="up", arms=("none", "none")), holding(28, False) + [(PACKET, 27, y), (ARROW_DOWN, 52, 12)]), 110)
        for y in (0, 7, 14, 20)
    ] + [
        (frame(crab(dy=1, eyes="squint", arms=("none", "none")), holding(28, True, 1) + [(PACKET, 27, 26)]), 160),
        (frame(crab(eyes="open", arms=("none", "none")), holding(28) + [(PACKET, 27, 25)]), 300),
        (frame(crab(dy=1, eyes="up", arms=("none", "none")), holding(29, True, 1) + [(PACKET, 27, 26)]), 110),
        (frame(crab(dy=-1, eyes="up", arms=("none", "none")), holding(23, True, -1) + [(PACKET, 27, 20)]), 90),
    ] + [
        (frame(crab(eyes="up", arms=("none", "none")), holding(26, False) + [(PACKET, 27, y), (ARROW_UP, 6, 12)]), 110)
        for y in (10, 0)
    ]),
    ("juggle", [
        (frame(crab(eyes="up", arms=("up", "up")), juggle(phase)), 150)
        for phase in range(6)
    ]),
    ("idle_look", [
        (frame(crab(eyes="left")), 700),
        (frame(crab(eyes="right")), 700),
        (frame(crab()), 300),
        (frame(crab(eyes="closed")), 110),
        (frame(crab()), 400),
        (frame(crab(eyes="squint", arms=(0, "none")), scratch(0)), 160),
        (frame(crab(eyes="squint", arms=(0, "none")), scratch(1)), 160),
        (frame(crab(eyes="squint", arms=(0, "none")), scratch(0)), 160),
        (frame(crab(eyes="squint", arms=(0, "none")), scratch(1)), 160),
        (frame(crab(dy=1)), 600),
    ]),
    ("idle_coffee_in", [
        (frame(crab(eyes="right", arms=(0, "none")), coffee(phase=0)), 200),
    ]),
    ("idle_coffee", [
        (frame(crab(eyes="right", arms=(0, "none")), coffee(phase=0)), 350),
        (frame(crab(eyes="right", arms=(0, "none")), coffee(phase=1)), 350),
        (frame(crab(eyes="right", arms=(0, "none")), coffee(phase=2)), 350),
        (frame(crab(eyes="closed", arms=(0, "none")), coffee(True, 0)), 450),
        (frame(crab(eyes="closed", arms=(0, "none")), coffee(True, 1)), 450),
        (frame(crab(dy=1, eyes="squint", arms=(0, "none")), coffee(phase=2) + [(HEART, 6, 28)]), 500),
        (frame(crab(eyes="squint", arms=(0, "none")), coffee(phase=0) + [(HEART, 6, 26)]), 500),
        (frame(crab(arms=(0, "none")), coffee(phase=1)), 400),
    ]),
    ("idle_music", [
        (frame(crab(dy=beat % 2, eyes="closed" if beat % 4 < 2 else "squint", arms=("none", "none")), [(headphones(beat % 2), 0, 0), (NOTE, (4, 52, 8, 56)[beat % 4], 30 - (beat % 2) * 4)]), 230)
        for beat in range(8)
    ]),
    ("idle_bubbles", [
        (frame(crab(eyes="right", arms=(0, "none")), [(wand(), 0, 0)]), 300),
        (frame(crab(eyes="closed", arms=(0, "none")), [(wand(True), 0, 0)]), 350),
    ] + [
        (frame(crab(eyes="up" if step < 5 else "squint", arms=(0, "none")), [(wand(step < 2), 0, 0), (bubbles(step), 0, 0)]), 200)
        for step in range(9)
    ]),
    ("idle_mania", [
        (frame(crab(dy=step % 2, eyes="up" if step != 4 else "wide", arms=("none", "none")), mania(step)), 140)
        for step in range(8)
    ] + [
        (frame(crab(dy=step % 2, eyes="up", arms=("none", "none")), mania(step)), 140)
        for step in range(8)
    ]),
    ("think", [
        (frame(crab(eyes="up"), [(TRAIL_TINY, 44, 33), (TRAIL_SMALL, 46, 29), (bubble(1), 48, 20)]), 320),
        (frame(crab(eyes="up"), [(TRAIL_TINY, 44, 33), (TRAIL_SMALL, 46, 29), (bubble(2), 48, 20)]), 320),
        (frame(crab(eyes="up"), [(TRAIL_TINY, 44, 33), (TRAIL_SMALL, 46, 29), (bubble(3), 48, 20)]), 320),
        (frame(crab(dy=1, eyes="up"), [(TRAIL_TINY, 44, 33), (TRAIL_SMALL, 46, 29), (bubble(3), 48, 20)]), 320),
    ]),
    ("work_read_in", [
        (frame(crab(), [(DEERSTALKER, 22, 18)]), 70),
        (frame(crab(), [(DEERSTALKER, 22, 27)]), 70),
        (frame(crab(dy=1), [(DEERSTALKER, 22, 32)]), 110),
        (frame(crab(arms=(0, "none")), [(DEERSTALKER, 22, 31), (lens("open"), 33, 42), (CLAW_PINCH, 42, 53)]), 110),
    ]),
    ("work_read", [
        (frame(crab(arms=(0, "none")), [(DEERSTALKER, 22, 31), (lens("open"), 33, 38), (CLAW_PINCH, 42, 49)]), 500),
        (frame(crab(dy=1, arms=(0, "none")), [(DEERSTALKER, 22, 32), (lens("open"), 33, 39), (CLAW_PINCH, 42, 50)]), 500),
        (frame(crab(arms=(0, "none")), [(DEERSTALKER, 22, 31), (lens("closed"), 33, 38), (CLAW_PINCH, 42, 49)]), 120),
        (frame(crab(arms=(0, "none")), [(DEERSTALKER, 22, 31), (lens("open"), 33, 38), (CLAW_PINCH, 42, 49)]), 500),
        (frame(crab(arms=(0, "none")), [(DEERSTALKER, 22, 31), (lens("open"), 33, 38), (CLAW_PINCH, 42, 49), (QUESTION, 8, 20)]), 700),
        (frame(crab(dy=1, arms=(0, "none")), [(DEERSTALKER, 22, 32), (lens("open"), 33, 39), (CLAW_PINCH, 42, 50), (QUESTION, 8, 19)]), 700),
    ]),
    ("work_read_out", [
        (frame(crab(arms=(0, "none")), [(DEERSTALKER, 22, 31), (lens("open"), 33, 42), (CLAW_PINCH, 42, 53)]), 100),
        (frame(crab(dy=1), [(DEERSTALKER, 22, 32)]), 100),
        (frame(crab(), [(DEERSTALKER, 22, 25)]), 70),
        (frame(crab(), [(DEERSTALKER, 22, 16)]), 70),
    ]),
    ("work_write_in", [
        (frame(crab(eyes="right"), [(glasses(-8, 1), 0, 0), ground(laptop_side("closed"), 46)]), 90),
        (frame(crab(eyes="right"), [(glasses(-3, 1), 0, 0), ground(laptop_side("half"), 46)]), 90),
        (frame(crab(dy=1, eyes="right"), [(glasses(1, 1), 0, 0), ground(laptop_side("open"), 46)]), 120),
    ]),
    ("work_write", [
        (frame(crab(eyes="right", arms=(0, "none")), [(glasses(0, 1), 0, 0), ground(laptop_side(), 46), (CLAW_DOWN, 46, 52)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(glasses(0, 1), 0, 0), ground(laptop_side(), 46), (CLAW_DOWN, 48, 53), (CODE_TILE, 44, 38)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(glasses(0, 1), 0, 0), ground(laptop_side(), 46), (CLAW_DOWN, 46, 52), (CODE_TILE, 44, 34)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(glasses(0, 1), 0, 0), ground(laptop_side(), 46), (CLAW_DOWN, 48, 53), (CODE_TILE, 44, 31)]), 400),
        (frame(crab(eyes="right", arms=(0, "none")), [(glasses(0, 1), 0, 0), ground(laptop_side(), 46), (CLAW_DOWN, 46, 52), (CODE_TILE, 44, 30)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(glasses(0, 1), 0, 0), ground(laptop_side(), 46), (CLAW_DOWN, 48, 53)]), 150),
        (frame(crab(dy=1, eyes="right", arms=(0, "none")), [(glasses(1, 1), 0, 0), ground(laptop_side(), 46), (CLAW_DOWN, 47, 53)]), 500),
    ]),
    ("work_write_out", [
        (frame(crab(eyes="right"), [(glasses(0, 1), 0, 0), ground(laptop_side("half"), 46)]), 90),
        (frame(crab(eyes="right"), [(glasses(-4, 1), 0, 0), ground(laptop_side("closed"), 46)]), 90),
        (frame(crab(), [(glasses(-9, 1), 0, 0)]), 80),
    ]),
    ("work_bash_in", [
        (frame(crab(eyes="right"), [(HARD_HAT, 23, 20), ground(crt_side("off"), 49)]), 80),
        (frame(crab(dy=1, eyes="right"), [(HARD_HAT, 23, 32), ground(crt_side("off"), 49)]), 100),
        (frame(crab(eyes="right"), [(HARD_HAT, 23, 31), ground(crt_side("flash"), 49), ground(KEYBOARD_SIDE, 39)]), 100),
    ]),
    ("work_bash", [
        (frame(crab(eyes="right", arms=(0, "none")), [(HARD_HAT, 23, 31), ground(crt_side(), 49), ground(KEYBOARD_SIDE, 39), (CLAW_DOWN, 40, 53)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(HARD_HAT, 23, 31), ground(crt_side(), 49), ground(KEYBOARD_SIDE, 39), (CLAW_DOWN, 43, 54)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(HARD_HAT, 23, 31), ground(crt_side(), 49), ground(KEYBOARD_SIDE, 39), (CLAW_DOWN, 40, 53)]), 150),
        (frame(crab(dy=1, eyes="right", arms=(0, "none")), [(HARD_HAT, 23, 32), ground(crt_side("flash"), 49), ground(KEYBOARD_SIDE, 39), (CLAW_DOWN, 41, 54)]), 90),
        (frame(crab(eyes="right", arms=(0, "none")), [(HARD_HAT, 23, 31), ground(crt_side(), 49), ground(KEYBOARD_SIDE, 39), (CLAW_DOWN, 41, 53), (SHELL_TILE, 48, 36)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(HARD_HAT, 23, 31), ground(crt_side(), 49), ground(KEYBOARD_SIDE, 39), (CLAW_DOWN, 41, 53), (SHELL_TILE, 48, 32)]), 150),
        (frame(crab(eyes="right", arms=(0, "none")), [(HARD_HAT, 23, 31), ground(crt_side(), 49), ground(KEYBOARD_SIDE, 39), (CLAW_DOWN, 41, 53), (SHELL_TILE, 48, 29)]), 500),
    ]),
    ("work_bash_out", [
        (frame(crab(eyes="right"), [(HARD_HAT, 23, 31), ground(crt_side("off"), 49), ground(KEYBOARD_SIDE, 39)]), 100),
        (frame(crab(eyes="right"), [(HARD_HAT, 23, 31), ground(crt_side("off"), 49)]), 80),
        (frame(crab(), [(HARD_HAT, 23, 22)]), 80),
    ]),
    ("work_web_in", [
        (frame(crab(eyes="right"), [(PITH_HELMET, 23, 20), ground(desk_globe(0), 47)]), 80),
        (frame(crab(dy=1, eyes="right"), [(PITH_HELMET, 23, 32), ground(desk_globe(0), 47)]), 100),
    ]),
    ("work_web", [
        (frame(crab(eyes="right", arms=(0, "none")), [(PITH_HELMET, 23, 31), ground(desk_globe(phase), 47), (CLAW_SIDE, 45 + (phase % 2), 46), (browser(phase), 40, 20)]), 150)
        for phase in range(9)
    ]),
    ("work_web_out", [
        (frame(crab(eyes="right"), [(PITH_HELMET, 23, 31), ground(desk_globe(0), 47)]), 100),
        (frame(crab(), [(PITH_HELMET, 23, 22), ground(desk_globe(0), 47)]), 80),
    ]),
    ("work_agent_in", [
        (frame(crab(), [(BOW_TIE, 27, 46), ground(mini(0), -6), ground(mini(0), 59)]), 120),
        (frame(crab(arms=(0, "none")), [(BOW_TIE, 27, 46), (conductor("up"), 0, 0), ground(mini(1), -2), ground(mini(1), 55)]), 120),
    ]),
    ("work_agent", [
        (frame(crab(arms=(0, "none")), [(BOW_TIE, 27, 46), (conductor("left"), 0, 0), ground(mini(0), 0), ground(mini(0), 53), (NOTE, 8, 30)]), 220),
        (frame(crab(dy=1, arms=(0, "none")), [(BOW_TIE, 27, 47), (conductor("up", 1), 0, 0), ground(mini(1), 0), ground(mini(1), 53), (NOTE, 6, 26)]), 220),
        (frame(crab(arms=(0, "none")), [(BOW_TIE, 27, 46), (conductor("right"), 0, 0), ground(mini(0), 0), ground(mini(0), 53), (NOTE, 56, 30)]), 220),
        (frame(crab(dy=1, arms=(0, "none")), [(BOW_TIE, 27, 47), (conductor("up", 1), 0, 0), ground(mini(1), 0), ground(mini(1), 53), (NOTE, 58, 26)]), 220),
    ]),
    ("work_agent_out", [
        (frame(crab(arms=(0, "none")), [(BOW_TIE, 27, 46), (conductor("up"), 0, 0), ground(mini(1), -2), ground(mini(1), 55)]), 110),
        (frame(crab(), [(BOW_TIE, 27, 46), ground(mini(0), -6), ground(mini(0), 59)]), 110),
    ]),
    ("attention", [
        (frame(crab(eyes="wide", arms=("none", "none")), alert(0, True, 1)), 150),
        (frame(crab(dy=-2, eyes="wide", arms=("none", "none")), alert(-2, True, -1)), 150),
        (frame(crab(eyes="wide", arms=("none", "none")), alert(0, False, 1)), 150),
        (frame(crab(dy=1, eyes="wide", arms=("none", "none")), alert(1, True, -1)), 150),
    ]),
    ("gone", [
        ([("." * FRAME)] * FRAME, 1000),
    ]),
    ("peek_in", [
        (frame(crab(eyes="left"), dx=40), 70),
        (frame(crab(eyes="left"), dx=30), 70),
        (frame(crab(eyes="left", arms=("none", 0)), alert(0, False, 0, 22, ("left",)), dx=22), 90),
    ]),
    ("peek", [
        (frame(crab(eyes="left", arms=("none", 0)), alert(0, True, 1, 22, ("left",)), dx=22), 200),
        (frame(crab(eyes="left", arms=("none", 0)), alert(0, True, -1, 22, ("left",)), dx=22), 200),
        (frame(crab(dy=1, eyes="left", arms=("none", 0)), alert(1, False, 1, 22, ("left",)), dx=22), 200),
        (frame(crab(eyes="left", arms=("none", 0)), alert(0, True, -1, 22, ("left",)), dx=22), 200),
    ]),
    ("peek_out", [
        (frame(crab(eyes="left"), dx=30), 70),
        (frame(crab(eyes="left"), dx=40), 70),
    ]),
] + [
    ("watch_" + gaze, [
        (frame(crab(eyes=gaze)), 900),
        (frame(crab(dy=1, eyes=gaze)), 700),
    ])
    for gaze in ("left", "right", "up", "down", "upleft", "upright")
] + [
    ("dizzy", [
        (starry(crab(dy=phase % 2, eyes=GOOGLY[phase % 4], arms=((0, 1), (1, 0))[phase % 2]), phase, (0, 1, 1, 1, 0, -1, -1, -1)[phase]), 110)
        for phase in range(8)
    ]),
    ("stagger", [
        (starry(crab(dy=phase % 2, lifts=((1, 0, 1, 0), (0, 0, 0, 0), (0, 1, 0, 1), (0, 0, 0, 0))[phase % 4], eyes=GOOGLY[phase % 4]), phase, (1, 1, 0, -1, -1, -1, 0, 1)[phase]), 120)
        for phase in range(8)
    ]),
    ("shaken", [
        (frame(crab(**AIR, lifts=((-3, 0, -3, 0), (0, -3, 0, -3))[phase % 2], eyes=GOOGLY[phase], arms=(("up", -2), (-2, "up"))[phase % 2]), [(SWEAT, (12, 48)[phase % 2], 30 + phase)], dx=(-2, 2)[phase % 2]), 70)
        for phase in range(4)
    ]),
    ("crash", [
        (pancake(), 260),
        (pancake(sum(stars(0, 43, 6, 15, 2), [])), 240),
        (pancake(sum(stars(2, 43, 6, 15, 2), [])), 240),
        (pancake(sum(stars(4, 43, 6, 15, 2), [])), 240),
        (frame(crab(dy=3, eyes="x", arms=("down", "down"))), 200),
    ]),
    ("splat", [
        (squashed(16, "x", True), 90),
        (squashed(24, "x"), 110),
        (squashed(19, "squint"), 150),
        (squashed(22, "squint"), 170),
    ]),
    ("slide", [
        (squashed(22, "squint", speed=1, dust=1, brace=True), 110),
        (squashed(22, "squint", speed=1, dust=2, brace=True), 110),
    ]),
    ("slide_fast", [
        (squashed(22, "x", speed=3, dust=3, brace=True), 70),
        (squashed(22, "x", speed=3, dust=2, brace=True), 70),
    ]),
    ("climb", [
        (climbing(step), 150)
        for step in range(4)
    ]),
    ("grapple", [
        (throwing(True), 220),
        (throwing(False), 600),
    ]),
    ("hang", [
        (hanging(0), 200),
        (hanging(1), 200),
    ]),
    ("hook", [
        (hook(), 1000),
    ]),
    ("inflate", [
        (inflating(radius), 300 if radius < 5 else 400)
        for radius in (1, 2, 3, 4, 5)
    ]),
    ("balloon", [
        (floating(sway, dy), 240)
        for sway, dy in ((0, 0), (1, 1), (0, 1), (1, 0))
    ]),
    ("dangle", [
        (dangling(step), 160 if eyes else 320)
        for step, eyes in zip(range(8), (0, 0, 1, 1, 1, 0, 0, 1))
    ]),
    ("balloon_out", [
        (floating(0, 0, True), 120),
        (floating(1, -1, True), 120),
    ]),
    ("sit_in", [
        (frame(crab(dy=2, arms=("down", "down"))), 110),
        (sitting(), 120),
    ]),
    ("sit", [
        (sitting("open", 0), 450),
        (sitting("open", 1), 450),
        (sitting("left", 0), 450),
        (sitting("left", 1), 450),
        (sitting("closed", 0), 110),
        (sitting("open", 1), 450),
        (sitting("right", 0), 450),
        (sitting("right", 1), 450),
        (sitting("squint", 0), 450),
        (sitting("squint", 1), 450),
    ]),
    ("sit_out", [
        (frame(crab(dy=2, arms=("down", "down"))), 110),
    ]),
    ("lookout", [
        (lookout(-1, 0), 650),
        (lookout(0, 1), 300),
        (lookout(1, 2), 650),
        (lookout(0, 1), 300),
        (lookout(-1, 0), 500),
        (lookout(0, 1, True), 600),
        (lookout(0, 1), 300),
    ]),
    ("parachute_hold", [
        (parachute(), 600),
        (parachute(1), 400),
    ]),
    ("parachute_walk", [
        (parachute(0, (1, 0, 1, 0)), 110),
        (parachute(1), 110),
        (parachute(0, (0, 1, 0, 1)), 110),
        (parachute(1), 110),
    ]),
    ("parachute", [
        (parachute(0, (-3, -2, -3, -2), "squint", 0), 260),
        (parachute(1, (-2, -3, -2, -3), "open", 1), 260),
    ]),
    ("teeter", [
        (teetering(step), 120)
        for step in range(4)
    ]),
]


AIRBORNE = {"jump", "fall", "grabbed", "gone", "poke_up", "shaken", "splat", "slide", "slide_fast",
            "climb", "hang", "hook", "balloon", "balloon_out", "dangle", "sit_in", "sit", "parachute"}


def check_floor():
    for name, sequence in ANIMATIONS:
        if name in AIRBORNE:
            continue
        for index, (rows, _) in enumerate(sequence):
            lowest = max(y for y, row in enumerate(rows) if row.strip("."))
            if lowest != FLOOR:
                raise SystemExit(f"{name} frame {index + 1} ends at y={lowest}, floor is y={FLOOR}")


def spec():
    check_floor()
    frames, tags = [], []
    for name, sequence in ANIMATIONS:
        start = len(frames) + 1
        frames += [{"rows": rows, "duration": duration} for rows, duration in sequence]
        tags.append({"name": name, "from": start, "to": len(frames)})
    return {
        "size": FRAME,
        "legend": PALETTE,
        "palette": list(PALETTE.values()),
        "body": BODY,
        "frames": frames,
        "tags": tags,
    }


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    assets = os.path.dirname(here)
    source = os.path.join(assets, "clawd.aseprite")
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as handle:
        json.dump(spec(), handle)
    try:
        subprocess.run([
            "aseprite", "-b",
            "--script-param", "spec=" + handle.name,
            "--script-param", "out=" + source,
            "--script", os.path.join(here, "build.lua"),
        ], check=True)
        staging = tempfile.mkdtemp(dir=assets)
        subprocess.run([
            "aseprite", "-b", source,
            "--sheet", os.path.join(staging, "clawd.png"),
            "--sheet-type", "rows",
            "--data", os.path.join(staging, "clawd.json"),
            "--format", "json-array",
            "--list-tags", "--list-slices",
        ], check=True, stdout=subprocess.DEVNULL)
        for name in ("clawd.png", "clawd.json"):
            os.replace(os.path.join(staging, name), os.path.join(assets, name))
        os.rmdir(staging)
    finally:
        os.unlink(handle.name)


if __name__ == "__main__":
    main()
