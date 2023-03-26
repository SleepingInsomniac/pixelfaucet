# first-order low-pass filter
class LowPassFilter
  @x1 : Float64
  @x2 : Float64
  @y1 : Float64
  @y2 : Float64
  @b0 : Float64
  @b1 : Float64
  @b2 : Float64
  @a1 : Float64
  @a2 : Float64

  def initialize(cutoff_frequency : Float64, quality_factor : Float64, sample_rate : Float64)
    # Compute the filter coefficients
    omega = 2.0 * Math::PI * cutoff_frequency / sample_rate
    sin_omega = Math.sin(omega)
    cos_omega = Math.cos(omega)
    alpha = sin_omega / (2.0 * quality_factor)

    b0 = (1.0 - cos_omega) / 2.0
    b1 = 1.0 - cos_omega
    b2 = b0
    a0 = 1.0 + alpha
    a1 = -2.0 * cos_omega
    a2 = 1.0 - alpha

    # Initialize the filter state
    @x1 = 0.0
    @x2 = 0.0
    @y1 = 0.0
    @y2 = 0.0

    # Store the filter coefficients
    @b0 = b0 / a0
    @b1 = b1 / a0
    @b2 = b2 / a0
    @a1 = a1 / a0
    @a2 = a2 / a0
  end

  def apply(sample : Float64) : Float64
    # Apply the filter to the sample
    output_sample = @b0 * sample + @b1 * @x1 + @b2 * @x2 - @a1 * @y1 - @a2 * @y2

    # Update the filter state variables
    @x2 = @x1
    @x1 = sample
    @y2 = @y1
    @y1 = output_sample

    output_sample
  end
end
