require "./spec_helper"
require "../src/noise"

include PF

describe Noise do
  describe ".cos_interpolate" do
    it "interpolates" do
      i = Noise.cosine_interpolate(0.0, 10.0, 0.5)
      (4.9..5.1).includes?(i).should eq(true)
    end
  end
end
