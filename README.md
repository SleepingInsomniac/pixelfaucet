# PixelFaucet Game

[![GitHub release](https://img.shields.io/github/release/sleepinginsomniac/pixelfaucet.svg)](https://github.com/sleepinginsomniac/pixelfaucet/releases)

An SDL2 based game engine

## Installation

1. Install sdl2

homebrew: `brew install sdl2`

2. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  pixelfaucet:
    github: sleepinginsomniac/pixelfaucet
```

3. Run `shards install`

## Usage

```crystal
require "pixelfaucet/game"

class Example < PF::Game
  def update(dt)
  end

  def draw
  end
end

e = Example.new(100, 60)
e.run!
```

## Contributing

1. Fork it (<https://github.com/your-github-user/pixel_faucet/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Alex Clink](https://github.com/your-github-user) - creator and maintainer
