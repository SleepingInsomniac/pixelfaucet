require "./spec_helper"
require "../src/game"

class Example < PF::Game
  def update(dt)
  end

  def draw
  end
end

describe PF::Game do
  it "Instantiates" do
    example = Example.new(100, 60)
    example.running = false
    example.run!
  end
end
