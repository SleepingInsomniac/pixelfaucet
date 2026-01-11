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
require "./keymap"
require "./animation"
require "./lehmer32"
require "../src/audio"
require "../src/audio/*"
require "../src/entity"
require "../src/entity/*"
require "./game"
