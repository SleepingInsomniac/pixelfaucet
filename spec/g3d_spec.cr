require "./spec_helper"
require "../src/g3d"
require "../src/vector"

describe "line_intersects_plane" do
  it "intersects a plane at a known point" do
    line_start = PF::Vector[0.0, 0.0, -5.0]
    line_end = PF::Vector[0.0, 0.0, 5.0]

    plane_normal = PF::Vector[0.0, 0.0, 1.0]
    plane_point = PF::Vector[0.0, 0.0, 0.0]

    intersect = PF::G3d.line_intersects_plane(plane_point, plane_normal, line_start, line_end)
    intersect.should eq(PF::Vector[0.0, 0.0, 0.0])
  end
end
