require "./sprite"
require "./particle"

module PF
  class Emitter < Sprite
    property emitting : Bool = true
    property particles = [] of Particle
    property max_age : Float64 = 1.0
    property emit_freq : Float64 = 0.05
    property strength : Float64 = 50.0
    getter last_emitted : Float64 = 0.0
    property emit_angle : Float64 = 2 * Math::PI
    property size : Float64 = 0.0

    # property color : Pixel = Pixel.new

    def generate_particle
      Particle.build do |particle|
        particle.position = @position

        if @size > 0.0
          particle.position.x += rand(-@size..@size)
          particle.position.y += rand(-@size..@size)
        end

        direction = rand((@rotation - @emit_angle)..(@rotation + @emit_angle))
        particle.velocity = @velocity + Vector2.new(Math.cos(direction), Math.sin(direction)) * @strength
        particle.lifespan = @max_age
      end
    end

    def update(dt : Float64)
      update_position(dt)

      @last_emitted += dt

      if @emitting && @last_emitted >= @emit_freq
        particle_count, remaining = @last_emitted.divmod(@emit_freq)
        particle_count.to_i.times do
          @particles << generate_particle
        end
        @last_emitted = remaining
      end

      @particles.each { |particle| particle.update(dt) }
      @particles.reject!(&.dead?)
    end

    def draw(engine)
      @particles.each do |particle|
        particle.draw(engine)
      end
    end
  end
end
