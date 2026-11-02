local file = io.open(app.params.spec)
local spec = json.decode(file:read("a"))
file:close()

local function color(hex)
  return Color{
    r = tonumber(hex:sub(2, 3), 16),
    g = tonumber(hex:sub(4, 5), 16),
    b = tonumber(hex:sub(6, 7), 16),
    a = 255
  }
end

local sprite = Sprite(spec.size, spec.size, ColorMode.RGB)
local colors = {}
for key, hex in pairs(spec.legend) do
  colors[key] = color(hex)
end

local palette = Palette(#spec.palette)
for index, hex in ipairs(spec.palette) do
  palette:setColor(index - 1, color(hex))
end
sprite:setPalette(palette)

local layer = sprite.layers[1]
layer.name = "clawd"
for _ = 2, #spec.frames do
  sprite:newEmptyFrame()
end

for index, frame in ipairs(spec.frames) do
  local image = Image(spec.size, spec.size, ColorMode.RGB)
  for y, row in ipairs(frame.rows) do
    for x = 1, #row do
      local pixel = colors[row:sub(x, x)]
      if pixel then
        image:drawPixel(x - 1, y - 1, pixel)
      end
    end
  end
  sprite:newCel(layer, index, image, Point(0, 0))
  sprite.frames[index].duration = frame.duration / 1000
end

for _, entry in ipairs(spec.tags) do
  local tag = sprite:newTag(entry.from, entry.to)
  tag.name = entry.name
end

local slice = sprite:newSlice(Rectangle(spec.body[1], spec.body[2], spec.body[3], spec.body[4]))
slice.name = "body"

sprite:saveAs(app.params.out)
