module PF
  VERSION = {% `shards version`.stringify %}
end

require "sdl3"
require "pf2d"
require "pixelfont"

require "./rgba"
require "./drawable"
require "./colors"
require "./interval"
require "./timeout"
require "./sprite"
require "./animation"
require "./lehmer32"
require "./audio"
require "./audio/*"
require "./entity"
require "./entity/*"
require "./window"
require "./key"
require "./keyboard"
require "./keymap"
require "./mouse"
require "./game"
