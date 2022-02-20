module PF
  struct Pixel
    def self.random
      new(rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), 0xFF_u8)
    end

    def self.white
      new(255, 255, 255)
    end

    def self.black
      new(0, 0, 0)
    end

    def self.red
      new(255, 0, 0)
    end

    def self.green
      new(0, 255, 0)
    end

    def self.blue
      new(0, 0, 255)
    end

    def self.yellow
      new(255, 255, 0)
    end

    def self.magenta
      new(255, 0, 255)
    end

    def self.cyan
      new(0, 255, 255)
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

    def *(n : Float64)
      PF::Pixel.new((@r * n).to_u8, (@g * n).to_u8, (@b * n).to_u8, @a)
    end

    def /(n : Float64)
      PF::Pixel.new((@r / n).to_u8, (@g / n).to_u8, (@b / n).to_u8, @a)
    end

    def +(n : Float64)
      PF::Pixel.new((@r + n).to_u8, (@g + n).to_u8, (@b + n).to_u8, @a)
    end

    def -(n : Float64)
      PF::Pixel.new((@r - n).to_u8, (@g - n).to_u8, (@b - n).to_u8, @a)
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
