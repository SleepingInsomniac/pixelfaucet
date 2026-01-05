module PF
  VERSION = {% `shards version`.stringify %}
end

require "sdl3"
require "pf2d"
require "pixelfont"

require "./rgba"
require "./colors"
require "./interval"
require "./sprite"
require "./keymap"
require "./animation"
require "./lehmer32"
require "./game"
