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
end
