module PF
  module Oscilator
    TWELFTH_ROOT = 2 ** (1 / 12)

    # Calculate a sine wave ~~~~~~~~
    def self.sin(hertz : Float64, time : Float64)
      Math.sin(av(hertz) * time)
    end

    # Calculate a square wave _|-|_|-|_
    def self.square(hertz : Float64, time : Float64)
      Math.sin(av(hertz) * time) > 0 ? 1.0 : 0.0
    end

    # Calculate a triangle wave /\/\/\/\/
    def self.triangle(hertz : Float64, time : Float64)
      Math.asin(Math.sin(av(hertz) * time)) * 2.0 / Math::PI
    end

    # Calculate a sawtooth wave by addition of sine waves
    # the more *sins* specified, the closer the waveform will
    # match a straight sawtooth wave
    # /|/|/|/|
    def self.saw(hertz : Float64, time : Float64, sins : Int)
      value = 0.0
      n = 0.0
      while (n += 1.0) < sins
        value += (Math.sin(n * av(hertz) * time)) / n
      end
      value * (2.0 / Math::PI)
    end

    # Calculate a sawtooth wave
    def self.saw(hertz : Float64, time : Float64)
      (2.0 / Math::PI) * (hertz * Math::PI * (time % (1.0 / hertz)) - (Math::PI / 2.0))
    end

    # Produces static noise
    def self.noise(hertz : Float64, time : Float64)
      rand(-1.0..1.0)
    end

    # Convert hertz into angular velocity
    def self.av(hertz)
      2.0 * Math::PI * hertz
    end
  end
end
