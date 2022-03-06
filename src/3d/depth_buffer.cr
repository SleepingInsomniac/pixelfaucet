module PF
  # A buffer of depth values for rending 3d scenes
  class DepthBuffer
    @values : Slice(Float64)
    @width : Int32
    @height : Int32

    def initialize(@width, @height)
      @values = Slice(Float64).new(@width * @height, 0.0)
    end

    def clear
      @values.fill(0.0)
    end

    def [](x : Int, y : Int)
      @values[y * @width + x]
    end

    def []=(x : Int, y : Int, value : Float64)
      @values[y * @width + x] = value
    end
  end
end
