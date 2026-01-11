module PF
  class Timeout
    property span : Time::Span
    @elapsed = 0u64.milliseconds
    getter? triggered = false
    getter? paused = false

    def initialize(@span)
    end

    def update(delta : Time::Span, &)
      return if paused? || triggered?

      @elapsed += delta

      if @elapsed >= @span
        yield unless triggered?
        @triggered = true
      end
    end

    def reset
      @elapsed = 0u64.milliseconds
      @triggered = false
    end

    def pause
      @paused = true
    end

    def resume
      @paused = false
    end
  end
end
