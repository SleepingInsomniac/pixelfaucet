require "./lehmer32"

module PF
  @[Experimental("Undergoing development")]
  struct Noise
    # Cosine interpolation
    def self.cosine_interpolate(point1 : Float64, point2 : Float64, position : Float64)
      ft = position * Math::PI
      f = (1 - Math.cos(ft)) * 0.5
      point1 * (1 - f) + point2 * f
    end

    # Linear interpolation
    def self.linear_interpolate(point1 : Float64, point2 : Float64, position : Float64)
      point1 * (1 - position) + point2 * position
    end

    @prng : Lehmer32
    @seed : UInt32

    def initialize(@seed = ::rand(UInt32))
      @prng = Lehmer32.new
    end

    # Returns 1d noise
    def get(x : Float64)
      x += @seed
      n1 = @prng.new_seed(x.to_u32!).rand(-1.0..1.0)
      n2 = @prng.new_seed(x.to_u32! + 1).rand(-1.0..1.0)
      Noise.cosine_interpolate(n1, n2, x - x.to_u32!)
    end

    # Returns 2d noise
    # def get(x : Float64, y : Float64)
    # end
  end
end
