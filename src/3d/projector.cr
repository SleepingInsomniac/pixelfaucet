require "../game"
require "./camera"

module PF
  class Projector
    getter width : Int32 | Float64
    getter height : Int32 | Float64
    property near = 0.1
    property far = 50.0
    getter fov = 70.0
    property aspect_ratio : Float64?
    property camera : Camera
    property light : Vector3(Float64) = Vector3.new(0.0, 0.0, -1.0).normalized
    property mat_proj : Matrix(Float64, 16)?
    property clipping_plane_near : Vector3(Float64)
    property clipping_plane_far : Vector3(Float64)

    @fov_rad : Float64?

    def initialize(@width, @height, @camera = Camera.new)
      @clipping_plane_near = Vector3.new(0.0, 0.0, @near)
      @clipping_plane_far = Vector3.new(0.0, 0.0, @far)
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
    def project(tris : Array(Tri), camera = @camera, sort : Bool = false)
      mat_view = camera.view_matrix

      # Only draw triangles facing the camera
      tris = tris.select do |tri|
        tri.normal.dot(tri.p1 - camera.position) < 0.0
      end

      # Iterate tris to transform into
      tris = tris.map do |tri|
        shade = (tri.normal.dot(light) + 1.0) / 2 # light should be normalized
        tri.color = tri.color * shade
        tri * mat_view
      end

      # Clip tris
      {
        {clipping_plane_near, Vector[0.0, 0.0, 1.0]},
        {clipping_plane_far, Vector[0.0, 0.0, -1.0]},
      }.each do |clip|
        0.upto(tris.size - 1) do
          tri = tris.pop
          tri.clip(plane: clip[0], plane_normal: clip[1]).each do |tri|
            tris.unshift(tri)
          end
        end
      end

      # Project the triangles
      tris = tris.map do |tri|
        z = tri.z
        tri *= mat_proj
        tri.z = z

        tri.map_points do |point|
          # Invert the y axis
          point.y *= -1.0

          # scale into screen space
          point += 1.0
          point.x *= 0.5 * width
          point.y *= 0.5 * height

          point
        end

        tri
      end

      # sort triangles, no need to do this if using a depth buffer
      tris.sort! { |a, b| b.z <=> a.z } if sort

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
