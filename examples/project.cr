require "../src/pixelfaucet"

class Project < PF::Game
  include PF2d

  @ray : Ray(Vec2(Float64)) = Ray[Vec[50.0, 50.0], Vec[1.0, 0.0]]
  @point : Vec2(Int32)= Vec[75, 25]
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def update(delta_time)
    @ray.dir = @ray.dir.rotate(1.0 * delta_time.to_f)
  end

  def frame(delta_time)
    proj = @ray.project(@point)
    proj_point = @ray.at(proj)

    lock do
      clear
      draw_line(@ray.pos, proj_point, PF::RGBA[0xFF999955])
      draw_line(@point, proj_point, PF::RGBA[0xFF999955])
      draw_line(@ray.pos, @point, PF::RGBA[0xFF999955])

      draw_line(@ray.pos, @ray.pos + @ray.dir * 50.0, PF::RGBA[0xFF0000FF])
      draw_point(@point, PF::RGBA[0x00FF00FF])
      draw_point(proj_point, PF::RGBA[0xFFFF00FF])

      if proj.positive?
        draw_string("In front", 2, 90, @font, PF::RGBA[0xFFFF0066])
      else
        draw_string("Behind", 2, 90, @font, PF::RGBA[0xFFFF0066])
      end
    end
  end
end

Project.new(100, 100, 3).run!
