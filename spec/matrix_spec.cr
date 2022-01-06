require "./spec_helper"
require "../src/matrix"

include PF

describe Matrix do
  it "Creates a square matrix with bracket notation" do
    m = Matrix[
      0, 1,
      1, 0,
    ]

    m.class.should eq(Matrix(Int32, 2, 2))
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

      mat.class.should eq(Matrix(Float64, 4, 4))

      ident = Matrix[
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]

      result = mat * ident
      result.should eq(mat)
    end
  end

  describe "#size" do
    it "returns the size of the matrix" do
      mat = Matrix[
        1, 2,
        3, 4,
      ]

      mat.size.should eq(2)
    end

    it "raises an exception if called on a non-square matrix" do
      mat = Matrix(Int32, 2, 4).new(Slice[
        1, 2,
        3, 4,
        5, 6,
        7, 8,
      ])

      expect_raises(Exception, "Matrix(2x4) is not square") { mat.size }
    end
  end
end
