require "../src/pixelfaucet"

# This example shows a perspective transform given 4 points.
# click and drag the points to distort the texture.
# The transform is calculated using a technique described by opencv called planar homography.
class Distort < PF::Game
  include PF2d
  include PF

  @sprite = PF::Sprite.new("assets/checkers.png")
  @quad : Quad(Float64)
  @hover : Vec2(Float64)*? = nil
  @selected : Vec2(Float64)*? = nil
  @transform = Transform.new

  def initialize(*args, **kwargs)
    super

    center = size / 2
    offset = center - @sprite.size / 2
    @quad = @sprite.quad + offset
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

      @transform
        .reset
        .distort(Quad[*@quad.points.map(&.floor)], @sprite.quad)

      @quad.bounding_box.each do |screen_point|
        sprite_point = @transform.apply(screen_point)

        if sample = @sprite[sprite_point]?
          draw_point(screen_point, sample)
        end
      end

      # draw(@quad.bounding_box, Colors::White)
      # draw(Rect[Vec[15, 15], @sprite.rect.size], Colors::Yellow)

      @quad.points.each { |p| draw(p, Colors::Green) }

      # @quad.points.each_cons_pair { |p1, p2| draw_line(p1, p2, RGBA[0xFF_FF_FF_22]) }
      # draw_line(@quad.p4, @quad.p1, RGBA[0xFF_FF_FF_22])

      if h = @hover
        draw(h.value, Colors::Red)
      end
    end
  end
end

Distort.new(200, 200, 4).run!
