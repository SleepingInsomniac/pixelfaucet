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
    property light : Vector3(Float64) = Vector3.new(0.0, 0.0, -1.0).normalized
    property mat_proj : Matrix(Float64, 16)?
    property clipping_plane_near : Vector3(Float64)
    property near_plane_normal : Vector3(Float64) = Vector3.new(0.0, 0.0, 1.0)
    @fov_rad : Float64?

    def initialize(@width, @height, @camera = Camera.new)
      @clipping_plane_near = Vector3.new(0.0, 0.0, @near)
    end

    def mat_proj
      @mat_proj ||= begin
        Matrix[
          aspect_ratio * fov_rad, 0.0, 0.0, 0.0,
          0.0, fov_rad, 0.0, 0.0,
          0.0, 0.0, far / (far - near), (-far * near) / (far - near),
          0.0, 0.0, 1.0, 0.0,
        ]
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

    # Project an array of Triangles into screen space
    def project(tris : Array(Tri), camera = @camera)
      mat_view = camera.view_matrix

      # only draw triangles facing the camera
      tris = tris.select do |tri|
        tri.normal.dot(tri.p1 - camera.position) < 0.0
      end

      # Iterate tris to transform into view, project, and clip
      0.upto(tris.size - 1) do
        tri = tris.pop
        shade = (tri.normal.dot(light) + 1.0) / 2 # light should be normalized
        tri.color = tri.color * shade

        tri *= mat_view

        # Clip against the near plane
        tri.clip(plane: clipping_plane_near, plane_normal: near_plane_normal).each do |tri|
          tri *= mat_proj

          # Invert the y axis
          tri.p1.y = tri.p1.y * -1.0
          tri.p2.y = tri.p2.y * -1.0
          tri.p3.y = tri.p3.y * -1.0

          # scale into screen space
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
      # TODO: Z-buffer
      tris.sort! { |a, b| b.z <=> a.z }

      # Clip against the edges of the screen
      {
        {Vector3.new(0.0, 0.0, 0.0), Vector3.new(0.0, 1.0, 0.0)},
        {Vector3.new(0.0, height - 1.0, 0.0), Vector3.new(0.0, -1.0, 0.0)},
        {Vector3.new(0.0, 0.0, 0.0), Vector3.new(1.0, 0.0, 0.0)},
        {Vector3.new(width - 1.0, 0.0, 0.0), Vector3.new(-1.0, 0.0, 0.0)},
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
