module PF
  struct Pixel
    def self.random
      new(rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), rand(0_u8..0xFF_u8), 0xFF_u8)
    end

    property r, g, b, a

    def initialize(@r : UInt8 = 255, @g : UInt8 = 255, @b : UInt8 = 255, @a : UInt8 = 255)
    end

    def format(format)
      LibSDL.map_rgba(format, @r, @g, @b, @a)
    end
  end
end
