require "./spec_helper"

include PF

describe RGBA do
  describe "#initialize" do
    it "breaks out a UInt32 into rgba components" do
      p = RGBA.new(0x11223344)
      p.red.should eq(0x11_u8)
      p.green.should eq(0x22_u8)
      p.blue.should eq(0x33_u8)
      p.alpha.should eq(0x44_u8)
    end
  end

  describe "#to_u32" do
    it "combines components into a UInt32 value" do
      p = RGBA.new(0x11_u8, 0x22_u8, 0x33_u8, 0x44_u8)
      p.to_u32.should eq(0x11223344_u32)
    end
  end
end
