# PixelFaucet Game

[![GitHub release](https://img.shields.io/github/release/sleepinginsomniac/pixelfaucet.svg)](https://github.com/sleepinginsomniac/pixelfaucet/releases)

PixelFaucet is a "Game Engine" written in the Crystal programming language and uses SDL2 under the hood to create a window, renderer, and draw pixels.
See the [examples](./examples).

The examples can be built by running the `./scripts/build_examples.rb` script. This will place the binaries in the `examples/build` folder.

## Setup

PixelFaucet requires the [crystal](https://crystal-lang.org) compiler which can be installed via [homebrew](https://brew.sh)

- Install crystal

```sh
brew install crystal
```

- Install sdl2

```sh
brew install sdl2
```

- Create a new project:

```sh
crystal init app my_game
```

- Add the dependency to your `shard.yml`:

```yaml
dependencies:
  pixelfaucet:
    github: sleepinginsomniac/pixelfaucet
```

- Run the shards command:

```sh
shards install
```

## Usage

```crystal
require "pixelfaucet/game"

class Example < PF::Game
  def update(dt)
  end

  def draw
    clear
    0.upto(width) do |x|
      0.upto(height) do |y|
        draw_point(x, y, PF::Pixel.random)
      end
    end
  end
end

e = Example.new(100, 60, 5)
e.run!
```

## Documentation

Run `crystal docs` to generate documentation. The documentation can then be found under the `docs` folder.

## Contributing

1. Fork it (<https://github.com/sleepinginsomniac/pixelfaucet/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Alex Clink](https://github.com/sleepinginsomniac) - creator and maintainer
