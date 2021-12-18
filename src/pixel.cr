module PF
  struct Pixel
    def self.random
      new(rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), 0xFF_u8)
    end

    def self.white
      new(255, 255, 255)
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
      @r = ((rgba & 0xFF000000_u32) >> (8 * 3)).to_u8
      @g = ((rgba & 0x00FF0000_u32) >> (8 * 2)).to_u8
      @b = ((rgba & 0x0000FF00_u32) >> 8).to_u8
      @a = ((rgba & 0x000000FF_u32)).to_u8
    end

    def initialize(@r : UInt8 = 255, @g : UInt8 = 255, @b : UInt8 = 255, @a : UInt8 = 255)
    end

    def format(format)
      LibSDL.map_rgba(format, @r, @g, @b, @a)
    end
  end
end
