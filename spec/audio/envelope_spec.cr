require "../spec_helper"
require "../../src/audio/envelope"

include PF

describe Envelope do
  describe "#stage" do
    it "returns the correct current stage" do
      attack = Envelope::Stage.new(0.5, 0.0, 1.0)
      decay = Envelope::Stage.new(0.1, 1.0, 0.8)
      sustain = Envelope::Stage.new(Float64::INFINITY, 0.8, 0.8)
      release = Envelope::Stage.new(0.5, 1.0, 0.0)

      env = Envelope.new(attack, decay, sustain, release)

      stage, time = env.stage(0.4)
      stage.should eq(attack)
      time.round(2).should eq(0.4)

      stage, time = env.stage(0.51)
      stage.should eq(decay)
      time.round(2).should eq(0.01)

      stage, time = env.stage(0.61)
      stage.should eq(sustain)
      time.round(2).should eq(0.01)
    end
  end

  describe "#amplitude" do
    it "returns a known amplitude" do
      attack = Envelope::Stage.new(1.0, 0.0, 1.0)
      decay = Envelope::Stage.new(1.0, 1.0, 0.8)
      sustain = Envelope::Stage.new(Float64::INFINITY, 0.8, 0.8)
      release = Envelope::Stage.new(1.0, 1.0, 0.0)

      env = Envelope.new(attack, decay, sustain, release)

      # half attack
      env.amplitude(time: 1.0, started_at: 0.5).should eq(0.5)
      # peak
      env.amplitude(time: 1.5, started_at: 0.5).should eq(1.0)
      # half decay
      env.amplitude(time: 2.0, started_at: 0.5).should eq(0.9)
      # sustain
      env.amplitude(time: 2.6, started_at: 0.5).should eq(0.8)
      # release at half of release time (sustain / 2)
      env.amplitude(time: 3.0, started_at: 0.5, released_at: 2.5).should eq(0.4)
    end
  end
end
