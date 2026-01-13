module PF
  class Key
    alias Code = Sdl3::Scancode

    @[Flags]
    enum State
      Down
      Repeat
      DownRead
      UpRead
      RepeatRead
    end

    getter state : State = State::None

    def initialize(@state = State::None)
    end

    def down=(value : Bool)
      if value
        @state |= State::Down
        @state &= ~State::DownRead
      else
        @state &= ~State::Down
        @state &= ~State::UpRead
      end
    end

    def repeat=(value : Bool)
      if value
        @state |= State::Repeat
        @state &= ~State::RepeatRead
      else
        @state &= ~State::Repeat
      end
    end

    def pressed?
      return false if @state.down_read?
      @state |= State::DownRead
      @state.down?
    end

    def released?
      return false if @state.up_read?
      @state |= State::UpRead
      !@state.down?
    end

    def held?
      @state.down?
    end

    def repeat?
      return false if @state.repeat_read?
      @state |= State::RepeatRead
      @state.repeat?
    end
  end
end
