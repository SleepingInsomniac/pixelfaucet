require "./spec_helper"
require "../src/pixel"

include PF

describe Pixel do
  describe "#initialize" do
    it "breaks out a UInt32 into rgba components" do
      p = Pixel.new(0x11223344)
      p.r.should eq(0x11_u8)
      p.g.should eq(0x22_u8)
      p.b.should eq(0x33_u8)
      p.a.should eq(0x44_u8)
    end
  end

  describe "#to_u32" do
    it "combines components into a UInt32 value" do
      p = Pixel.new(0x11_u8, 0x22_u8, 0x33_u8, 0x44_u8)
      p.to_u32.should eq(0x11223344_u32)
    end
  end
end
