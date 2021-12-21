module PF
  class Mesh
    setter tris = [] of Tri
    property origin = Vec3d(Float64).new(0.0, 0.0, 0.0)
    property rotation = Vec3d(Float64).new(0.0, 0.0, 0.0)
    property position = Vec3d(Float64).new(0.0, 0.0, 0.0)

    # Load an obj file
    def self.load_obj(path, use_normals : Bool = false)
      verticies = [] of Vec3d(Float64)
      texture_verticies = [] of Vec3d(Float64)
      normal_verticies = [] of Vec3d(Float64)
      tris = [] of Tri

      line_no = 0
      File.open(path) do |file|
        file.each_line do |line|
          line_no += 1
          next if line =~ /^\s*$/
          parts = line.split(/\s+/)
          case parts[0]
          when "v"
            w = parts[4]?.try { |n| n.to_f64 }
            verticies << Vec3d.new(x: parts[1].to_f64, y: parts[2].to_f64, z: parts[3].to_f64, w: w)
          when "vt"
            v = parts[2]?.try { |n| n.to_f64 } || 0.0
            w = parts[3]?.try { |n| n.to_f64 } || 0.0
            texture_verticies << Vec3d.new(parts[1].to_f64, v, w)
          when "vn"
            if use_normals
              normal_verticies << Vec3d.new(parts[1].to_f64, parts[2].to_f64, parts[3].to_f64)
            end
          when "f"
            face_verts = [] of Vec3d(Float64)
            normal : Vec3d(Float64)? = nil
            parts[1..].each do |part|
              face = part.split('/')
              face_verts << verticies[face[0].to_i - 1]

              # If the normal is specified, use that. (other Tri calculates this based on clockwise winding)
              if use_normals
                if n_index = face[2]?
                  normal = normal_verticies[n_index.to_i - 1]
                end
              end
            end
            tris << Tri.new(face_verts[0], face_verts[1], face_verts[2], normal: normal)

            # Split a square into triangles
            if face_verts.size > 3
              tris << Tri.new(face_verts[0], face_verts[2], face_verts[3], normal: normal)
            end
          end
        end
      end

      new(tris)
    end

    def initialize(@tris)
    end

    def tris
      # Translate and rotate
      @tris.map do |tri|
        tri *= Mat4.translation(origin)
        tri *= Mat4.rotation(rotation)
        tri *= Mat4.translation(position)
        tri
      end
    end
  end
end
