require "../game"
require "./camera"

module PF
  class Projector
    getter width : Int32 | Float64
    getter height : Int32 | Float64
    property near = 0.1
    property far = 1000.0
    getter fov = 90.0
    property aspect_ratio : Float64?
    property camera : Camera
    property light : Vec3d(Float64) = Vec3d.new(0.0, 0.0, -1.0).normalized
    property mat_proj : Mat4?
    property clipping_plane_near : Vec3d(Float64)
    property near_plane_normal : Vec3d(Float64) = Vec3d.new(0.0, 0.0, 1.0)
    @fov_rad : Float64?

    def initialize(@width, @height, @camera = Camera.new)
      @clipping_plane_near = Vec3d.new(0.0, 0.0, @near)
    end

    def mat_proj
      @mat_proj ||= begin
        Mat4.new(Slice[
          aspect_ratio * fov_rad, 0.0, 0.0, 0.0,
          0.0, fov_rad, 0.0, 0.0,
          0.0, 0.0, far / (far - near), (-far * near) / (far - near),
          0.0, 0.0, 1.0, 0.0,
        ])
      end
    end

    def width=(value)
      @aspect_ratio = nil
      @width = value
    end

    def height=(value)
      @aspect_ratio = nil
      @height = value
    end

    def aspect_ratio
      @aspect_ratio ||= height / width
    end

    def fov=(value)
      @fov_rad = nil # remove memoized value
      @fov = value
    end

    def fov_rad
      @fov_rad ||= 1.0 / Math.tan(@fov * 0.5 / 180.0 * Math::PI)
    end

    def project(tris : Array(Tri), camera = @camera)
      mat_view = camera.view_matrix

      # only draw triangles facing the camera
      tris = tris.select do |tri|
        tri.normal.dot(tri.p1 - camera.position) < 0.0
      end

      0.upto(tris.size - 1) do
        tri = tris.pop
        shade = (tri.normal.dot(light) + 1.0) / 2 # light should be normalized
        tri.color = tri.color * shade.clamp(0.0..1.0)

        tri.p1 *= mat_view
        tri.p2 *= mat_view
        tri.p3 *= mat_view

        tri.clip(plane: clipping_plane_near, plane_normal: near_plane_normal).each do |tri|
          tri.p1 *= mat_proj
          tri.p2 *= mat_proj
          tri.p3 *= mat_proj

          # Invert the y axis
          tri.p1.y = tri.p1.y * -1.0
          tri.p2.y = tri.p2.y * -1.0
          tri.p3.y = tri.p3.y * -1.0

          tri.p1 += 1.0
          tri.p2 += 1.0
          tri.p3 += 1.0

          tri.p1.x = tri.p1.x * 0.5 * width
          tri.p1.y = tri.p1.y * 0.5 * height
          tri.p2.x = tri.p2.x * 0.5 * width
          tri.p2.y = tri.p2.y * 0.5 * height
          tri.p3.x = tri.p3.x * 0.5 * width
          tri.p3.y = tri.p3.y * 0.5 * height

          tris.unshift(tri)
        end
      end

      # sort triangles
      tris = tris.sort { |a, b| b.z <=> a.z }

      # Clip against the edges of the screen
      {
        {Vec3d.new(0.0, 0.0, 0.0), Vec3d.new(0.0, 1.0, 0.0)},
        {Vec3d.new(0.0, height - 1.0, 0.0), Vec3d.new(0.0, -1.0, 0.0)},
        {Vec3d.new(0.0, 0.0, 0.0), Vec3d.new(1.0, 0.0, 0.0)},
        {Vec3d.new(width - 1.0, 0.0, 0.0), Vec3d.new(-1.0, 0.0, 0.0)},
      }.each do |clip|
        0.upto(tris.size - 1) do
          tri = tris.pop
          tri.clip(plane: clip[0], plane_normal: clip[1]).each do |tri|
            tris.unshift(tri)
          end
        end
      end

      tris # Return the fully projected triangles
    end
  end
end
