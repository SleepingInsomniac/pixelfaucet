module PF
  struct Lehmer32
    include Random

    @state : UInt32

    def initialize(@state = ::rand(UInt32))
    end

    def new_seed(n : Number)
      @state = n.to_u32!
      self
    end

    # Generate the next number in the sequence
    def next_u
      @state &+= 0xe120fc15
      tmp : UInt64 = @state.to_u64! &* 0x4a39b70d
      m1 : UInt32 = ((tmp >> 32) ^ tmp).to_u32!
      tmp = m1.to_u64! &* 0x12fad5c9
      ((tmp >> 32) ^ tmp).to_u32!
    end
  end
end
