module PF
  struct RGBA
    macro [](*args)
      {{@type}}.new({{args.splat}})
    end

    property value : UInt32

    def self.random : RGBA
      new(rand(0u32..UInt32::MAX) | 255u32)
    end

    def self.from_hsva(h : Float, s : Float, v : Float, a : Float)
      c = v * s
      x = c * (1 - ((h / 60.0) % 2 - 1).abs)
      m = v - c

      r, g, b =
        case h
        when 0...60    then {c, x, 0}
        when 60...120  then {x, c, 0}
        when 120...180 then {0, c, x}
        when 180...240 then {0, x, c}
        when 240...300 then {x, 0, c}
        else
          {c, 0, x}
        end

      r = (((r + m) * UInt8::MAX).clamp(0, UInt8::MAX)).to_u8
      g = (((g + m) * UInt8::MAX).clamp(0, UInt8::MAX)).to_u8
      b = (((b + m) * UInt8::MAX).clamp(0, UInt8::MAX)).to_u8
      a = ((a * UInt8::MAX).clamp(0, UInt8::MAX)).to_u8

      RGBA.new(r, g, b, a)
    end

    def initialize(red : UInt8, green : UInt8, blue : UInt8, alpha : UInt8 = 255u8)
      @value = (red.to_u32 << 24) | (green.to_u32 << 16) | (blue.to_u32 << 8) | alpha.to_u32
    end

    def initialize(@value : UInt32)
    end

    def channels
      {red, green, blue, alpha}
    end

    def rgb
      {red, green, blue}
    end

    def red
      (@value >> 24).to_u8
    end

    def red=(value : UInt8)
      @value = (@value & 0x00ffffffu32) | (value.to_u32 << 24)
    end

    def green
      ((@value >> 16) & 255u8).to_u8
    end

    def green=(value : UInt8)
      @value = (@value & 0xff00ffffu32) | (value.to_u32 << 16)
    end

    def blue
      ((@value >> 8) & 255u8).to_u8
    end

    def blue=(value : UInt8)
      @value = (@value & 0xffff00ffu32) | (value.to_u32 << 8)
    end

    def alpha
      (@value & 0xffu32).to_u8
    end

    def alpha=(value : UInt8)
      @value = (@value & 0xffffff00u32) | value.to_u32
    end

    def to_u32
      @value
    end

    {% for op in %w[* / // + -] %}
      def {{op.id}}(n : Number)
        RGBA.new(*rgb.map { |c| (c {{op.id}} n).clamp(0, UInt8::MAX).to_u8 }, alpha)
      end

      def {{op.id}}(other : RGBA)
        RGBA.new(red {{op.id}} other.red, green {{op.id}} other.green, blue {{op.id}} other.blue, alpha)
      end
    {% end %}

    def lerp_value(v1 : UInt8, v2 : UInt8, t : Float64) : UInt8
      (v1.to_f64 + (v2.to_f64 - v1.to_f64) * t).round.clamp(0.0, 255.0).to_u8
    end

    def lerp(other : RGBA, t : Float64 = 0.5)
      RGBA.new(
        lerp_value(red, other.red, t),
        lerp_value(green, other.green, t),
        lerp_value(blue, other.blue, t),
        alpha
      )
    end

    # Alpha blending: source (self) over dest
    def blend(dest : RGBA) : RGBA
      sc = channels.map(&.to_f32)
      dc = dest.channels.map(&.to_f32)
      a_s, a_d = sc[3] / 255, dc[3] / 255

      a_b = a_s + a_d * (1.0 - a_s)

      return RGBA.new(0u8, 0u8, 0u8, 0u8) if a_b <= 0.0

      blend = -> (s : Float32, d : Float32) {
        ((s * a_s + d * a_d * (1.0 - a_s)) / a_b).clamp(0.0, 255.0).round.to_u8
      }
      blended = sc[0..2].map_with_index { |s, i| blend.call(s, dc[i]) }

      a = (a_b * 255.0).clamp(0.0, 255.0).round.to_u8

      RGBA.new(*blended, a)
    end

    def add(other : RGBA)
      RGBA.new(
        ((red.to_u16 + other.red) // 2).to_u8,
        ((green.to_u16 + other.green) // 2).to_u8,
        ((blue.to_u16 + other.blue) // 2).to_u8
      )
    end

    def darken(other : RGBA)
      RGBA.new(
        (red * (other.red / 255)).to_u8,
        (green * (other.green / 255)).to_u8,
        (blue * (other.blue / 255)).to_u8
      )
    end

    def lighten(amount : Float)
      self + (PF::Colors::White - self) * amount
    end

    def darken(amount : Float)
      self * (1.0 - amount)
    end
  end
end
