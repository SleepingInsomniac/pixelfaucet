module PF
  module BirthTime
    {% if Crystal::VERSION < "1.19.0" %}
      getter started_at : Float64 = Time.monotonic.total_milliseconds
    {% else %}
      getter started_at : Time::Instant = Time.instant
    {% end %}

    def reset_birthtime
      {% if Crystal::VERSION < "1.19.0" %}
        @started_at = Time.monotonic.total_milliseconds
      {% else %}
        @started_at = Time.instant
      {% end %}
    end

    # Return the elapsed time
    def elapsed_time
      {% if Crystal::VERSION < "1.19.0" %}
        (Time.monotonic.total_milliseconds - @started_at).milliseconds
      {% else %}
        @started_at.elapsed
      {% end %}
    end
  end
end
