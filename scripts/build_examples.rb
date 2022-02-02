#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'

options = {
  release: true,
  debug: false,
  clean: false,
}

OptionParser.new do |opts|
  opts.banner = "Usage: build_examples.rb [options]"

  opts.on("--release", "Build in release mode") do
    options[:release] = true
  end

  opts.on("--no-release", "Build faster") do
    options[:release] = false
  end

  opts.on("--clean", "Remove built examples") do
    options[:clean] = true
  end
end.parse!

unless options[:clean]
  cmd = "crystal build"
  flags = []
  flags << "--release" if options[:release]
  flags << "--no-debug" unless options[:debug]

  Dir.chdir File.join(__dir__, '..')
  FileUtils.mkdir_p("examples/build")
  FileUtils.rm("examples/build/assets")
  FileUtils.ln_s("../../assets", "examples/build/assets")
  Dir.glob("examples/*.cr").each do |path|
    full_cmd = %'#{cmd} #{flags.join(" ")} "#{path}"'
    puts full_cmd
    system full_cmd
    bin_name = File.basename(path, ".cr")
    FileUtils.mv(bin_name, "examples/build/#{bin_name}")
  end
else
  # TODO
end
