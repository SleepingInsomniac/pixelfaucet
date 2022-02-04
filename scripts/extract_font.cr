require "../src/game"

mapping : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!?().,/\\[]{}$#+-“”‘’'\"@=><_"
tiles = PF::Sprite.load_tiles("assets/pf-font.png", 7, 8)

puts "CHARS = {"
tiles.each_with_index do |tile, i|
  if letter = mapping[i]?
    if ['\\', '\''].includes? letter
      print "  '\\#{letter}' => "
    else
      print "  '#{letter}'  => "
    end

    n = 0u64
    mask = 1_u64 << (7 * 8)

    tile.pixels.each do |pixel|
      n |= mask if pixel >> 8 <= 127
      mask >>= 1
    end

    puts "0x#{n.to_s(16).rjust(16, '0')}_u64,"
  end
end
puts "}"
