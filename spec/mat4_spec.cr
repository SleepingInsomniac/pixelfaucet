require "./spec_helper"
require "../src/3d/*"

describe PF::Mat4 do
  describe "#*" do
    it "returns the same matrix when multiplied by identity" do
      mat = PF::Mat4.new(Slice[
        1.0, 2.0, 3.0, 4.0,
        1.0, 2.0, 3.0, 4.0,
        1.0, 2.0, 3.0, 4.0,
        1.0, 2.0, 3.0, 4.0,
      ])

      ident = PF::Mat4.identity

      result = mat * ident
      result.should eq(mat)
    end
  end
end
