struct EchoEffect
  @cursor : Int32 = 0

  def initialize(frames : Int32)
    @buffer = Slice(Float64).new(frames, 0.0)
    @filter = LowPassFilter.new(440.0, 0.7, 44100)
  end

  def read
    @buffer[@cursor]
  end

  def write(sample : Float64)
    @buffer[@cursor] = sample
    @cursor += 1
    @cursor = 0 if @cursor >= @buffer.size
  end

  def apply(sample : Float64, strength = 0.5)
    sample += @filter.apply(read * strength)
    write(sample)
    sample
  end
end
