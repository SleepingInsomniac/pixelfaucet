require "../src/pixelfaucet"

include PF
include PF2d

# checkers.png
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c1 = Colors::Red
c2 = Colors::Green
c3 = Colors::Blue
c4 = Colors::Yellow

s = Sprite.new(64, 64)
s.each_point do |p|
  lr = c1.lerp(c2, p.x / s.width)
  tb = c3.lerp(c4, p.y / s.height)
  c = lr.lerp(tb)

  pp = p // 8
  c = (pp.x + pp.y) % 2 == 0 ? c : c.darken(0.5)
  c = (p.x + p.y) % 2 == 0 ? c.lighten(0.1) : c.darken(0.1)
  s.draw_point(p, c)
end

font = Pixelfont::Font.new("lib/pixelfont/fonts/pixel-3x5.txt")
color = RGBA[0xFFFFFFAAu32]
s.draw_string("1", 1, 1, font, fore: color)
s.draw_string("2", s.width - 5, 1, font, fore: color)
s.draw_string("3", s.width - 5, s.height - 7, font, fore: color)
s.draw_string("4", 1, s.height - 7, font, fore: color)

s.save("assets/checkers.png")
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
