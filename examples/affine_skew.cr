require "../src/pixelfaucet"

# click and drag corner points to move the 4 points of the quad. The quad is split into 2 triangles
# and a texture is sampled across them. This kind of transformation does not preserve perspective.
# the PS1 did not correct for perspective and used a similar method.
class AffineSkew < PF::Game
  include PF2d
  include PF

  @sprite = PF::Sprite.new("assets/checkers.png")
  @quad : Quad(Float64)
  @hover : Vec2(Float64)*? = nil
  @selected : Vec2(Float64)*? = nil

  def initialize(*args, **kwargs)
    super

    offset = Vec[15, 15]

    @quad = Quad[
      Vec[0.0,  0.0]  + offset,
      Vec[63.0, 0.0]  + offset,
      Vec[63.0, 63.0] + offset,
      Vec[0.0,  63.0] + offset,
    ]
  end

  def on_mouse_down(event : Event)
    @selected = @hover
  end

  def on_mouse_up(event : Event)
    @selected = nil
  end

  def on_mouse_motion(direction, event)
    @hover = @quad.point_pointers.find { |p| PF::Mouse.pos.distance(p.value) < 4 }

    if s = @selected
      s.value = Mouse.pos
    end
  end

  def update(delta_time)
  end

  def frame(delta_time)
    lock do
      clear

      td1, td2 = @quad.tris
      ts1, ts2 = @sprite.rect.tris(Float64)

      td1.map_points(ts1) do |src, dst|
        if sample = @sprite[src]?
          draw_point(dst, sample)
        end
      end

      td2.map_points(ts2) do |src, dst|
        if sample = @sprite[src]?
          draw_point(dst, sample)
        end
      end

      draw(Rect[Vec[15, 15], @sprite.rect.size], Colors::Yellow)

      @quad.points.each { |p| draw(p, Colors::Green) }

      if h = @hover
        draw(h.value, Colors::Red)
      end
    end
  end
end

AffineSkew.new(100, 100, 9).run!
