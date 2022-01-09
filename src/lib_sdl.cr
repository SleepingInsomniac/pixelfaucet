require "sdl"

@[Link("SDL2")]
lib LibSDL
  # These macros don't work inside of the PixelFormatEnum

  # macro define_pixelfourcc(a, b, c, d)
  #  {{a}}.ord.to_u32 << 0 |
  #  {{b}}.ord.to_u32 << 8 |
  #  {{c}}.ord.to_u32 << 16 |
  #  {{d}}.ord.to_u32 << 24
  # end

  # macro define_pixelformat(type, order, layout, bits, bytes)
  #   1 << 28 | {{type}} << 24 | {{order}} << 20 | {{layout}} << 16 | {{bits}} << 8 | {{bytes}} << 0
  # end

  enum PixelFormatEnum : UInt32
    UNKNOWN
    INDEX1LSB   = 1 << 28 | PixelType::INDEX1 << 24 | BitmapOrder::SDL_BITMAPORDER_4321 << 20 | 0 << 16 | 1 << 8 | 0
    INDEX1MSB   = 1 << 28 | PixelType::INDEX1 << 24 | BitmapOrder::SDL_BITMAPORDER_1234 << 20 | 0 << 16 | 1 << 8 | 0
    INDEX4LSB   = 1 << 28 | PixelType::INDEX4 << 24 | BitmapOrder::SDL_BITMAPORDER_4321 << 20 | 0 << 16 | 4 << 8 | 0
    INDEX4MSB   = 1 << 28 | PixelType::INDEX4 << 24 | BitmapOrder::SDL_BITMAPORDER_1234 << 20 | 0 << 16 | 4 << 8 | 0
    INDEX8      = 1 << 28 | PixelType::INDEX8 << 24 | 0 << 20 | 0 << 16 | 8 << 8 | 1
    RGB332      = 1 << 28 | PixelType::PACKED8 << 24 | PackedOrder::XRGB << 20 | PackedLayout::L332 << 16 | 8 << 8 | 1
    RGB444      = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::XRGB << 20 | PackedLayout::L4444 << 16 | 12 << 8 | 2
    RGB555      = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::XRGB << 20 | PackedLayout::L1555 << 16 | 15 << 8 | 2
    BGR555      = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::XBGR << 20 | PackedLayout::L1555 << 16 | 15 << 8 | 2
    ARGB4444    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::ARGB << 20 | PackedLayout::L4444 << 16 | 16 << 8 | 2
    RGBA4444    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::RGBA << 20 | PackedLayout::L4444 << 16 | 16 << 8 | 2
    ABGR4444    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::ABGR << 20 | PackedLayout::L4444 << 16 | 16 << 8 | 2
    BGRA4444    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::BGRA << 20 | PackedLayout::L4444 << 16 | 16 << 8 | 2
    ARGB1555    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::ARGB << 20 | PackedLayout::L1555 << 16 | 16 << 8 | 2
    RGBA5551    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::RGBA << 20 | PackedLayout::L5551 << 16 | 16 << 8 | 2
    ABGR1555    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::ABGR << 20 | PackedLayout::L1555 << 16 | 16 << 8 | 2
    BGRA5551    = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::BGRA << 20 | PackedLayout::L5551 << 16 | 16 << 8 | 2
    RGB565      = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::XRGB << 20 | PackedLayout::L565 << 16 | 16 << 8 | 2
    BGR565      = 1 << 28 | PixelType::PACKED16 << 24 | PackedOrder::XBGR << 20 | PackedLayout::L565 << 16 | 16 << 8 | 2
    RGB888      = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::XRGB << 20 | PackedLayout::L8888 << 16 | 24 << 8 | 4
    RGBX8888    = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::RGBX << 20 | PackedLayout::L8888 << 16 | 24 << 8 | 4
    BGR888      = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::XBGR << 20 | PackedLayout::L8888 << 16 | 24 << 8 | 4
    BGRX8888    = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::BGRX << 20 | PackedLayout::L8888 << 16 | 24 << 8 | 4
    ARGB8888    = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::ARGB << 20 | PackedLayout::L8888 << 16 | 32 << 8 | 4
    RGBA8888    = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::RGBA << 20 | PackedLayout::L8888 << 16 | 32 << 8 | 4
    ABGR8888    = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::ABGR << 20 | PackedLayout::L8888 << 16 | 32 << 8 | 4
    BGRA8888    = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::BGRA << 20 | PackedLayout::L8888 << 16 | 32 << 8 | 4
    ARGB2101010 = 1 << 28 | PixelType::PACKED32 << 24 | PackedOrder::ARGB << 20 | PackedLayout::L2101010 << 16 | 32 << 8 | 4
    YV12        =  842094169
    IYUV        = 1448433993
    YUY2        =  844715353
    UYVY        = 1498831189
    YVYU        = 1431918169
  end
end

module SDL
  class Surface
    def pixels
      surface.pixels
    end
  end

  abstract struct Event
    struct Keyboard < Event
      def scancode
        _event.keysym.scancode
      end
    end
  end
end
