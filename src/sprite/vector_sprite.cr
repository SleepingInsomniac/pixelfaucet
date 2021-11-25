module PF
  module VectorSprite
    def self.generate_circle(num_points : Int, size = 1.0, jitter = 0.0) : Array(Vector2)
      0.upto(num_points).map do |n|
        angle = (2 * Math::PI) * (n / num_points)

        x = size + rand(-jitter..jitter)

        rc = Math.cos(angle)
        rs = Math.sin(angle)
        Vector2.new(0.0 * rc - x * rs, x * rc + 0.0 * rs)
      end.to_a
    end

    property frame = [] of Vector2
    @average_radius : Float64? = nil

    def project_points(points : Array(Vector2), rotation = self.rotation, translate : Vector2? = nil, scale : Vector2? = nil)
      rc = Math.cos(rotation)
      rs = Math.sin(rotation)

      translation =
        if t = translate
          self.position + t
        else
          self.position
        end

      points.map do |point|
        rotated = Vector2.new(point.x * rc - point.y * rs, point.y * rc + point.x * rs)

        scale.try do |scale|
          rotated = rotated * scale
        end

        translation + rotated
      end
    end

    # Calculated as the average R for all points in the frame
    def radius
      average_radius
    end

    # Calculated as the average R for all points in the frame
    def average_radius
      @average_radius ||= begin
        # calculate length from center for all points
        lengths = frame.map do |vec|
          Math.sqrt(vec.x ** 2 + vec.y ** 2)
        end

        # get the average of the lengths
        lengths.reduce { |t, p| t + p } / frame.size.to_f
      end
    end

    def draw_frame(engine : Game, frame = @frame, color : Pixel = Pixel.new)
      0.upto(frame.size - 1) do |n|
        engine.draw_line(frame[n], frame[(n + 1) % frame.size], color)
      end
    end

    def draw_radius(engine : Game, points = 30, color : Pixel = Pixel.new)
      circle = self.class.generate_circle(points, average_radius).map do |point|
        point + @position
      end
      draw_frame(engine, frame: circle, color: color)
    end
  end
end
