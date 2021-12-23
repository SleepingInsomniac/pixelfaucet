require "./spec_helper"
require "sdl"
require "../src/controller"

describe PF::Controller do
  it "detects my keyboard" do
    SDL.init(SDL::Init::VIDEO)
    PF::Controller.detect_layout.should eq(:dvorak)
    SDL.quit
  end
end
