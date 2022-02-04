module PF
  class Sprite
    CHARS = {
      'A'  => 0x007112244f912200_u64,
      'B'  => 0x00f1122788913c00_u64,
      'C'  => 0x0071120408111c00_u64,
      'D'  => 0x00f1122448913c00_u64,
      'E'  => 0x00f1020708103c00_u64,
      'F'  => 0x00f1020788102000_u64,
      'G'  => 0x0071122409911c00_u64,
      'H'  => 0x00891227c8912200_u64,
      'I'  => 0x0070408102041c00_u64,
      'J'  => 0x0078204081121800_u64,
      'K'  => 0x009122860a122400_u64,
      'L'  => 0x0081020408103c00_u64,
      'M'  => 0x0089b2a448912200_u64,
      'N'  => 0x008992a4c8912200_u64,
      'O'  => 0x0071122448911c00_u64,
      'P'  => 0x00f1122788102000_u64,
      'Q'  => 0x007112244a931e00_u64,
      'R'  => 0x00f112278a122200_u64,
      'S'  => 0x0071120380911c00_u64,
      'T'  => 0x00f8408102040800_u64,
      'U'  => 0x0089122448911c00_u64,
      'V'  => 0x00891224488a0800_u64,
      'W'  => 0x01064c9ab5512200_u64,
      'X'  => 0x0089114105112200_u64,
      'Y'  => 0x0089114102040800_u64,
      'Z'  => 0x00f8104104103e00_u64,
      'a'  => 0x0000018087121c00_u64,
      'b'  => 0x0081038489123800_u64,
      'c'  => 0x0000018488121800_u64,
      'd'  => 0x001021c489121c00_u64,
      'e'  => 0x000001848e101c00_u64,
      'f'  => 0x0061220708102000_u64,
      'g'  => 0x00000184890e0470_u64,
      'h'  => 0x0081038489122400_u64,
      'i'  => 0x0000400102040800_u64,
      'j'  => 0x0000200081021410_u64,
      'k'  => 0x008102450c142400_u64,
      'l'  => 0x0000810204080800_u64,
      'm'  => 0x000003454a912200_u64,
      'n'  => 0x000002468b122400_u64,
      'o'  => 0x0000018489121800_u64,
      'p'  => 0x00000184891c2040_u64,
      'q'  => 0x000001c4890e0408_u64,
      'r'  => 0x0000018488102000_u64,
      's'  => 0x000001c406023800_u64,
      't'  => 0x0040838204080800_u64,
      'u'  => 0x0000022448911c00_u64,
      'v'  => 0x00000224488a0800_u64,
      'w'  => 0x000002244a951400_u64,
      'x'  => 0x00000222820a2200_u64,
      'y'  => 0x00000224488f0238_u64,
      'z'  => 0x000003e082083e00_u64,
      '0'  => 0x007112654c911c00_u64,
      '1'  => 0x0060408102041c00_u64,
      '2'  => 0x0071102184103e00_u64,
      '3'  => 0x0071102180911c00_u64,
      '4'  => 0x00891223c0810200_u64,
      '5'  => 0x00f9020780911c00_u64,
      '6'  => 0x0071120788911c00_u64,
      '7'  => 0x00f8104104081000_u64,
      '8'  => 0x0071122388911c00_u64,
      '9'  => 0x00711223c0911c00_u64,
      '!'  => 0x0020408102000800_u64,
      '?'  => 0x0071122182000800_u64,
      '('  => 0x0020810204080800_u64,
      ')'  => 0x0040408102041000_u64,
      '.'  => 0x0000000000000800_u64,
      ','  => 0x0000000000000410_u64,
      '/'  => 0x0010408204102000_u64,
      '\\' => 0x0080810102020400_u64,
      '['  => 0x00c1020408103000_u64,
      ']'  => 0x00c0810204083000_u64,
      '{'  => 0x0060810404081800_u64,
      '}'  => 0x00c0810104083000_u64,
      '$'  => 0x0020f283829e0800_u64,
      '#'  => 0x0050a3e28f8a1400_u64,
      '+'  => 0x00004087c2040000_u64,
      '-'  => 0x00000007c0000000_u64,
      '“'  => 0x0041228100000000_u64,
      '”'  => 0x0021214200000000_u64,
      '‘'  => 0x0041020000000000_u64,
      '’'  => 0x0080810000000000_u64,
      '\'' => 0x0040810000000000_u64,
      '"'  => 0x00a1428000000000_u64,
      '@'  => 0x007112e54b901e00_u64,
      '='  => 0x000003e00f800000_u64,
      '>'  => 0x0040404041041000_u64,
      '<'  => 0x0008208202020200_u64,
      '_'  => 0x0000000000003e00_u64,
    }
    CHAR_WIDTH  = 7
    CHAR_HEIGHT = 8

    def draw_string(msg : String, x : Int, y : Int, color : Pixel = Pixel.black, bg : Pixel? = nil)
      cur_y = 0
      cur_x = 0
      leading = 0

      msg.chars.each do |c|
        if c == '\n'
          cur_y += 1
          cur_x = 0
          next
        end

        if char = CHARS[c]?
          mask = 1_u64 << (CHAR_WIDTH * CHAR_HEIGHT)

          0.upto(CHAR_HEIGHT - 1) do |cy|
            0.upto(CHAR_WIDTH - 1) do |cx|
              if mask & char > 0
                draw_point(x + cx + (cur_x * CHAR_WIDTH), y + cy + (cur_y * (CHAR_HEIGHT + leading)), color)
              elsif background = bg
                draw_point(x + cx + (cur_x * CHAR_WIDTH), y + cy + (cur_y * (CHAR_HEIGHT + leading)), background)
              end
              mask >>= 1
            end
          end
        end

        cur_x += 1
      end
    end

    def draw_string(msg : String, pos : Vector2(Int), color : Pixel = Pixel.black)
      draw_string(msg, pos.x, pos.y, color)
    end
  end
end
