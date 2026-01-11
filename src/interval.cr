module PF
  class Interval
    property every : Time::Span
    @interval = 0u64.milliseconds
    getter? paused = false

    def initialize(@every)
    end

    def update(delta : Time::Span, &)
      return if @paused

      @interval += delta

      if @interval >= @every
        @interval -= @every
        yield
      end
    end

    def reset
      @interval = 0u64.milliseconds
    end

    def pause
      @paused = true
    end

    def resume
      @paused = false
    end
  end
end
