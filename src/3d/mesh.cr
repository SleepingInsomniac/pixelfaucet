module PF
  # Mesh represents a collection of points and triangles
  # TODO: Keep points in a collection, removing duplicates, and keep triangle verticies pointing to the points in that collection
  class Mesh
    setter tris = [] of Tri
    property origin : Vector3(Float64) = Vector[0.0, 0.0, 0.0]
    property rotation : Vector3(Float64) = Vector[0.0, 0.0, 0.0]
    property position : Vector3(Float64) = Vector[0.0, 0.0, 0.0]

    # Load an obj file
    # TODO: Load meshes specified by the obj file
    def self.load_obj(path, use_normals : Bool = false)
      verticies = [] of Vector3(Float64)
      texture_verticies = [] of Vector3(Float64)
      normal_verticies = [] of Vector3(Float64)
      tris = [] of Tri

      line_no = 0
      File.open(path) do |file|
        file.each_line do |line|
          line_no += 1
          next if line =~ /^\s*$/
          parts = line.split(/\s+/)

          case parts[0]
          when "o"
            puts "Object: #{parts[1]}"
            # TODO: This is when a new mesh starts
          when "mtllib"
            # TODO This is where we need to load texture and material information
          when "v"
            w = parts[4]?.try { |n| n.to_f64 }
            verticies << Vector3.new(x: parts[1].to_f64, y: parts[2].to_f64, z: parts[3].to_f64)
          when "vt"
            v = parts[2]?.try { |n| n.to_f64 } || 0.0
            w = parts[3]?.try { |n| n.to_f64 } || 1.0
            texture_verticies << Vector3.new(parts[1].to_f64, v, w)
          when "vn"
            if use_normals
              normal_verticies << Vector3.new(parts[1].to_f64, parts[2].to_f64, parts[3].to_f64)
            end
          when "f"
            face_verts = [] of Vector3(Float64)
            face_tex = [] of Vector3(Float64)

            normal : Vector3(Float64)? = nil
            parts[1..].each do |part|
              face = part.split('/')
              face_verts << verticies[face[0].to_i - 1]

              if tex_index = face[1]?
                face_tex << texture_verticies[face[1].to_i - 1]
              end

              # If the normal is specified, use that. (other Tri calculates this based on clockwise winding)
              if use_normals
                if n_index = face[2]?
                  normal = normal_verticies[n_index.to_i - 1]
                end
              end
            end

            tri = Tri.new(face_verts[0], face_verts[1], face_verts[2], normal: normal)

            # set the face texture coords if specified
            unless face_tex.empty?
              tri.t1 = face_tex[0]
              tri.t2 = face_tex[1]
              tri.t3 = face_tex[2]
            end

            tris << tri

            # Split a square into triangles
            if face_verts.size > 3
              tri = Tri.new(face_verts[0], face_verts[2], face_verts[3], normal: normal)
              unless face_tex.empty?
                tri.t1 = face_tex[0]
                tri.t2 = face_tex[2]
                tri.t3 = face_tex[3]
              end
              tris << tri
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
        tri *= Transform3d.translation(origin)
        tri *= Transform3d.rotation(rotation)
        tri *= Transform3d.translation(position)
        tri
      end
    end
  end
end
