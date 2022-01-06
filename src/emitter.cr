require "./entity"
require "./particle"

module PF
  class Emitter < Entity
    property emitting : Bool = true
    property particles = [] of Particle
    property max_age : Float64 = 1.0
    property emit_freq : Float64 = 0.05
    property strength : Float64 = 50.0
    getter last_emitted : Float64 = 0.0
    property emit_angle : Float64 = 2 * Math::PI
    property size : Float64 = 0.0

    def generate_particle
      particle = Particle.new
      particle.position = @position

      if @size > 0.0
        particle.position.x += rand(-@size..@size)
        particle.position.y += rand(-@size..@size)
      end

      direction = rand((@rotation - @emit_angle)..(@rotation + @emit_angle))
      particle.velocity = @velocity + Vector[Math.cos(direction), Math.sin(direction)] * @strength
      particle.lifespan = @max_age
      particle
    end

    def update(dt : Float64)
      super(dt)

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
