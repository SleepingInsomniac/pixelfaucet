# PixelFaucet Game

[![GitHub release](https://img.shields.io/github/release/sleepinginsomniac/pixelfaucet.svg)](https://github.com/sleepinginsomniac/pixelfaucet/releases)

PixelFaucet is a "Game Engine" written in the Crystal programming language and uses [SDL](https://github.com/sleepinginsomniac/sdl3.cr) under the hood to create a window, draw pixels, and expose hardware interfaces.

See the [examples](./examples).

The examples can either be run with `crystal run examples/<name>.cr` from the root of the repo, or be all built by running the `./scripts/build_examples.rb` script. This will place the binaries in the `examples/build` folder.

## Setup

PixelFaucet requires the [crystal](https://crystal-lang.org) compiler which can be installed via [homebrew](https://brew.sh)

- Install crystal

```sh
brew install crystal
```

- Install sdl3

```sh
brew install sdl3
brew install sdl3_image
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
    version: 0.2.2 # Or the current version
```

- Run the shards command:

```sh
shards install
```

## Usage

The engine works be subclassing the `PF::Game` which requires two methods be defined:

```crystal
require "pixelfaucet"

class Static < PF::Game
  # Called every game tick
  def update(delta_time : Time::Span)
  end

  # Called at a rate to satify `fps_limit` (Float::INFINITY by default)
  def frame(delta_time)
    window.lock do
      window.clear
      window.each_point { |p| window.draw_point(p, PF::RGBA.random) }
    end
  end
end

e = Example.new(100, 60, 5)
e.run!
```

Drawing methods come from [PF2d](https://github.com/SleepingInsomniac/pf2d). `PF::Window` and `PF::Sprite` implement the `PF2d::Canvas(PF:RGBA)` module which provides methods for drawing points, lines, rects, circles, bezier curves, triangles, and more.

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
