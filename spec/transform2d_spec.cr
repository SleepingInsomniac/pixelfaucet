require "./spec_helper"
require "../src/transform2d"

include PF

describe Transform2d do
  describe "#translate" do
    it "creates the same matrix as matrix multiplication" do
      t = Transform2d.new
      t.translate(-1.0, -2.0).rotate(0.5).scale(1.1).translate(1.0, 2.0)

      m = Transform2d.translation(-1.0, -2.0)
      m = Transform2d.rotation(0.5) * m
      m = Transform2d.scale(1.1, 1.1) * m
      m = Transform2d.translation(1.0, 2.0) * m

      t.matrix.should eq(m)
    end
  end
end
