module PF
  abstract class Voice
    delegate :start, :release, :held?, :released?, to: @envelope
    property envelope : Envelope
    property note : Note

    def initialize(@note : Note, time : Float64)
      @envelope = Envelope.new(time)
    end

    abstract def hertz(time : Float64)
  end
end
