require "./colors"

module PF
  struct Pixel
    def self.random
      new(rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), 0xFF_u8)
    end

    property r : UInt8, g : UInt8, b : UInt8, a : UInt8

    def initialize(rgba : UInt32)
      @r = (rgba >> 24).to_u8!
      @g = (rgba >> 16).to_u8!
      @b = (rgba >> 8).to_u8!
      @a = (rgba).to_u8!
    end

    def initialize(@r : UInt8 = 255, @g : UInt8 = 255, @b : UInt8 = 255, @a : UInt8 = 255)
    end

    def format(format)
      LibSDL.map_rgba(format, @r, @g, @b, @a)
    end

    def blend_value(v1 : UInt8, v2 : UInt8, t : Float64) : UInt8
      f1 = v1 / UInt8::MAX
      f2 = v2 / UInt8::MAX
      v = Math.sqrt((1 - t) * f1 ** 2 + t * f2 ** 2)
      (v * UInt8::MAX).to_u8
    end

    def blend(other : Pixel, t : Float64 = 0.5)
      Pixel.new(
        blend_value(@r, other.r, t),
        blend_value(@g, other.g, t),
        blend_value(@b, other.b, t),
        @a
      )
    end

    def add(other : Pixel)
      Pixel.new(
        ((@r.to_u16 + other.r) // 2).to_u8,
        ((@g.to_u16 + other.g) // 2).to_u8,
        ((@b.to_u16 + other.b) // 2).to_u8
      )
    end

    def darken(other : Pixel)
      Pixel.new(
        (@r * (other.r / 255)).to_u8,
        (@g * (other.g / 255)).to_u8,
        (@b * (other.b / 255)).to_u8
      )
    end

    def *(n : Float64)
      Pixel.new((@r * n).to_u8, (@g * n).to_u8, (@b * n).to_u8, @a)
    end

    def /(n : Float64)
      Pixel.new((@r / n).to_u8, (@g / n).to_u8, (@b / n).to_u8, @a)
    end

    def +(n : Float64)
      Pixel.new((@r + n).to_u8, (@g + n).to_u8, (@b + n).to_u8, @a)
    end

    def -(n : Float64)
      Pixel.new((@r - n).to_u8, (@g - n).to_u8, (@b - n).to_u8, @a)
    end

    def to_u
      to_u32
    end

    def to_u32
      value = uninitialized UInt32
      value = @r.to_u32 << 24
      value |= @g.to_u32 << 16
      value |= @b.to_u32 << 8
      value |= @a.to_u32
      value
    end
  end
end
