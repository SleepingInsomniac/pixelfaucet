module PF
  module Shape
    # Generate an array of points that form a circle
    def self.circle(num_points : Int, size = 1.0, jitter = 0.0)
      0.upto(num_points).map do |n|
        angle = (2 * Math::PI) * (n / num_points)
        x = size + rand(-jitter..jitter)
        rc = Math.cos(angle)
        rs = Math.sin(angle)
        Point.new(0.0 * rc - x * rs, x * rc + 0.0 * rs)
      end.to_a
    end

    # Rotate points by *rotation*
    def self.rotate(points : Enumerable(Point), rotation : Float64)
      rc = Math.cos(rotation)
      rs = Math.sin(rotation)

      points.map do |point|
        Point.new(point.x * rc - point.y * rs, point.y * rc + point.x * rs)
      end
    end

    # Translate points by *translation*
    def self.translate(points : Enumerable(Point), translation : Point)
      points.map { |p| p + translation }
    end

    # ditto
    def self.translate(*points : Point, translation : Point)
      self.translation(points, translation: translation)
    end

    # Scale points by a certain *amount*
    def self.scale(points : Enumerable(Point), amount : Point)
      points.map { |p| p * amount }
    end

    # calculate length from center for all points, and then get the average
    def self.average_radius(points : Enumerable(Point))
      points.map(&.length).reduce { |t, p| t + p } / frame.size
    end
  end
end
