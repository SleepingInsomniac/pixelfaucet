class Mesh
  property tris = [] of Tri

  def initialize(@tris)
  end

  def self.load(path)
    verticies = [] of Vec3d(Float64)
    tris = [] of Tri

    line_no = 0
    File.open(path) do |file|
      file.each_line do |line|
        line_no += 1
        next if line =~ /^\s*$/
        parts = line.split(/\s+/)
        case parts[0]
        when "v"
          verticies << Vec3d.new(parts[1].to_f64, parts[2].to_f64, parts[3].to_f64)
        when "f"
          face_verts = [] of Vec3d(Float64)
          parts[1..3].each do |part|
            face = part.split('/')
            face_verts << verticies[face[0].to_i - 1]
          end
          tris << Tri.new(face_verts[0], face_verts[1], face_verts[2])
        end
      end
    end

    new(tris)
  end
end
