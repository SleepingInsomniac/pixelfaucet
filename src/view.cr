module PF
  @[Experimental("May change")]
  class View
    include PF2d

    @transform : PF2d::Transform = PF2d::Transform.new

    getter origin : Vec2(Float64) = Vec[0.0, 0.0]
    getter zoom = 1.0
    getter pan : Vec2(Float64) = Vec[0.0, 0.0]
    getter rotation = 0.0
    getter? stale = true
    property min_zoom = 0.1
    property max_zoom = 100.0

    private def recalculate
      @stale = false
      @transform
        .reset
        .translate(-@origin)
        .scale(@zoom)
        .translate(@pan)
    end

    def origin=(point)
      @stale = true
      @origin = point
    end

    def pan(delta)
      @stale = true
      @pan += delta
      self
    end

    def pan(delta)
      @stale = true
      @pan += delta
      self
    end

    def zoom(delta)
      @stale = true
      @zoom += delta
      self
    end

    def zoom=(value)
      @stale = true
      @zoom = value
    end

    def zoom_at(screen_p : PF2d::Vec2, zoom_delta : Float)
      @stale = true
      world_p = (screen_p - @pan) / @zoom + @origin
      @zoom += zoom_delta * 0.4
      @zoom = @zoom.clamp(min_zoom, max_zoom)
      @pan = screen_p - (world_p - @origin) * @zoom
      self
    end

    def map(x, y)
      recalculate if stale?
      @transform.apply(x, y)
    end

    def map(point : Vec2)
      recalculate if stale?
      @transform.apply(point)
    end

    def map(points : Enumerable(Vec))
      recalculate if stale?
      @transform.apply(points)
    end

    # TODO: optimize?
    def unmap(point : Vec2)
      recalculate if stale?
      matrix = Transform.invert(@transform.matrix)
      PF2d::Vec[x.to_f, y.to_f, 1.0] * matrix
    end
  end
end
