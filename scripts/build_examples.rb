#!/usr/bin/env ruby

v_major, v_minor, v_patch = RUBY_VERSION.split('.').map(&:to_i)
unless v_major == 3 && v_minor >= 2
  $stderr.puts "Warn: script designed for Ruby 3.2.x, running: #{RUBY_VERSION}"
end

require 'optparse'
require 'fileutils'

OUT_PATH = 'examples/build'

options = {
  release: true,
  debug: false,
}

OptionParser.new do |opts|
  opts.banner = "Usage: build_examples.rb [options]"

  opts.on("--[no-]release", "Build in release mode (default: #{options[:release]})") do |value|
    options[:release] = value
  end

  opts.on("--[no-]debug", "Include debug information (default: #{options[:debug]})") do |value|
    options[:debug] = value
  end
end.parse!

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cmd = "crystal build"
flags = []
flags << "--release" if options[:release]
flags << "--no-debug" unless options[:debug]

Dir.chdir File.join(__dir__, '..')
FileUtils.mkdir_p(OUT_PATH)

unless File.exist?("#{OUT_PATH}/assets")
  FileUtils.ln_s("../../assets", "#{OUT_PATH}/assets")
end

Dir.glob("examples/*.cr").each do |path|
  bin_name = File.basename(path, ".cr")
  full_cmd = %'#{cmd} #{flags.join(" ")} "#{path}" -o #{OUT_PATH}/#{bin_name}'
  puts full_cmd
  system full_cmd
end
