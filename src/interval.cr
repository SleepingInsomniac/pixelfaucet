module PF
  class Interval
    property every : Time::Span
    @interval = 0u64.milliseconds

    def initialize(@every)
    end

    def update(delta : Time::Span, &)
      @interval += delta
      if @interval >= @every
        @interval -= @every
        yield
      end
    end
  end
end
