module PF
  class Mouse
    @@instance : self?

    def self.instance
      @@instance ||= new
    end

    def self.pos
      instance.pos
    end

    def self.any_held?
      instance.buttons.values.any?(&.held?)
    end

    def self.[](id : String)
      instance.buttons[id] ||= Key.new
    end

    def self.raw_state
      Sdl3::Mouse.state
    end

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    getter buttons = {} of String => Key
    getter pos : Vec2(Float64) = PF2d::Vec[0.0, 0.0]

    private def initialize
    end

    # Updated by the engine
    def update_state(pos, flags : Sdl3::Mouse::Button)
      @pos = pos
      self["left"].down   = flags.left?
      self["middle"].down = flags.middle?
      self["right"].down  = flags.right?
    end

    def [](id : String)
      @buttons[id] ||= Key.new
    end
  end
end
