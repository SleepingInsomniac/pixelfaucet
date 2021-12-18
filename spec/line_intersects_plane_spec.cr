require "./spec_helper"
require "../src/3d/*"

describe "line_intersects_plane" do
  it "intersects a plane at a known point" do
    line_start = Vec3d.new(0.0, 0.0, -5.0)
    line_end = Vec3d.new(0.0, 0.0, 5.0)

    plane_normal = Vec3d.new(0.0, 0.0, 1.0)
    plane_point = Vec3d.new(0.0, 0.0, 0.0)

    intersect = Vec3d.line_intersects_plane(plane_point, plane_normal, line_start, line_end)

    intersect.should eq(Vec3d.new(0.0, 0.0, 0.0))
  end
end
