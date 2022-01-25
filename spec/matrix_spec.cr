require "./spec_helper"
require "../src/matrix"

include PF

describe Matrix do
  it "Creates a square matrix with bracket notation" do
    m = Matrix[
      0, 1,
      1, 0,
    ]

    m.class.should eq(Matrix(Int32, 4))
    m[1, 0].should eq(1)
    m[0, 1].should eq(1)
  end

  describe "#*" do
    it "returns the same matrix when multiplied by identity" do
      mat = Matrix[
        1.0, 2.0, 3.0, 4.0,
        1.0, 2.0, 3.0, 4.0,
        1.0, 2.0, 3.0, 4.0,
        1.0, 2.0, 3.0, 4.0,
      ]

      mat.class.should eq(Matrix(Float64, 16))

      ident = Matrix[
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]

      result = mat * ident
      result.should eq(mat)
    end

    it "multiplies different types" do
      m1 = Matrix[1, 2, 3, 4]
      m2 = Matrix[2.0, 0.0, 0.0, 2.0]
      m3 = Matrix[2.0, 4.0, 6.0, 8.0]
      (m1 * m2).should eq(m3)
    end
  end

  describe "#size" do
    it "returns the size of the matrix" do
      mat = Matrix[
        1, 2,
        3, 4,
      ]

      mat.width.should eq(2)
    end
  end

  describe "#==" do
    it "accurately show equality" do
      m1 = Matrix[
        1, 1, 1,
        1, 1, 1,
        1, 1, 1,
      ]

      m2 = Matrix[
        1, 1, 1,
        1, 1, 1,
        1, 1, 1,
      ]

      m3 = Matrix[
        2, 2, 2,
        2, 2, 2,
        2, 2, 2,
      ]

      (m1 == m2).should eq(true)
      (m1 == m3).should eq(false)
    end
  end
end
