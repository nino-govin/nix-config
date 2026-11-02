PALETTE = {
    "O": "#2B1A14",
    "M": "#7E3A28",
    "D": "#A9533A",
    "B": "#D97757",
    "H": "#F0A07F",
    "L": "#F7C8AE",
    "E": "#1C110D",
    "W": "#FFF6EE",
    "K": "#3B4252",
    "G": "#8F99A8",
    "g": "#C7CED9",
    "S": "#8ED8F8",
    "N": "#7A4B2A",
    "Y": "#FFD45E",
    "R": "#E5534B",
    "V": "#7BD88F",
    "T": "#C9A26B",
    "t": "#8E6B3F",
    "c": "#E2D6B5",
    "C": "#B3A47F",
    "b": "#3F7FD0",
    "y": "#C9961C",
    "Q": "#81A1C1",
    "P": "#5E81AC",
    "p": "#46628A",
    "F": "#FF66AA",
}


class Canvas:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.grid = [["."] * width for _ in range(height)]

    def px(self, x, y, color):
        if 0 <= x < self.width and 0 <= y < self.height:
            self.grid[y][x] = color

    def get(self, x, y):
        if 0 <= x < self.width and 0 <= y < self.height:
            return self.grid[y][x]
        return "."

    def rect(self, x0, y0, x1, y1, color):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.px(x, y, color)

    def rows(self, x, y, rows):
        for j, row in enumerate(rows):
            for i, color in enumerate(row):
                if color != ".":
                    self.px(x + i, y + j, color)

    def line(self, x0, y0, x1, y1, color):
        steps = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(steps + 1):
            self.px(round(x0 + (x1 - x0) * i / steps), round(y0 + (y1 - y0) * i / steps), color)

    def paste(self, other, x, y):
        self.rows(x, y, other.lines())

    def outline(self, color="O"):
        sides = ((1, 0), (-1, 0), (0, 1), (0, -1))
        added = [
            (x, y)
            for y in range(self.height)
            for x in range(self.width)
            if self.grid[y][x] == "."
            and any(self.get(x + dx, y + dy) not in (".", color) for dx, dy in sides)
        ]
        for x, y in added:
            self.grid[y][x] = color
        return self

    def mirrored(self):
        other = Canvas(self.width, self.height)
        other.grid = [row[::-1] for row in self.grid]
        return other

    def lines(self):
        return ["".join(row) for row in self.grid]
