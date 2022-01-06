require "./spec_helper"
require "../src/vector"

include PF

describe Vector do
  describe "#*" do
    it "multiplies 2 vectors" do
      v1 = Vector[1, 2]
      v2 = Vector[2, 2]
      (v1 * v2).should eq(Vector(Int32, 2).new(2, 4))
    end
  end

  describe "#magnitude" do
    it "returns the magnitude a vector" do
      v1 = Vector[2, 2]
      v1.magnitude.should eq(2.8284271247461903)
    end
  end

  describe "#dot" do
    it "returns a known dot product" do
      v1 = Vector[6, 2, -1]
      v2 = Vector[5, -8, 2]
      v1.dot(v2).should eq(12)
    end
  end

  describe "#cross" do
    it "returns a known cross product" do
      v1 = Vector[0, 0, 2]
      v2 = Vector[0, 2, 0]
      v1.cross(v2).should eq(Vector[-4, 0, 0])
    end
  end

  describe "#x" do
    it "returns the x positional value" do
      v1 = Vector[1, 2]
      v1.x.should eq(1)
    end
  end

  describe "standard operations" do
    it "adds" do
      v1 = Vector[1, 2]
      v2 = Vector[3, 4]
      (v1 + v2).should eq(Vector[4, 6])
    end

    it "does modulus" do
      v1 = Vector[5, 10]
      v2 = Vector[3, 3]
      (v1 % v2).should eq(Vector[2, 1])
    end

    it "does division" do
      v1 = Vector[5, 5]
      (v1 / 2).should eq(Vector[2.5, 2.5])
    end

    it "does integer division" do
      v1 = Vector[5, 5]
      (v1 // 2).should eq(Vector[2, 2])
    end
  end

  describe "type conversion" do
    it "converts float to int" do
      v = Vector[1.5, 2.5]
      v.to_i32.should eq(Vector[1, 2])
    end
  end
end
