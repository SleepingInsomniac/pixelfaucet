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

Dir.chdir(File.expand_path(File.join(__dir__, "..")))

unless options[:clean]
  cmd = "crystal build"
  flags = []
  flags << "--release" if options[:release]
  flags << "--no-debug" unless options[:debug]
  flags << "--output \"examples/build\""
  flags << "--progress"

  Dir.chdir File.join(__dir__, '..')
  FileUtils.mkdir_p("examples/build")

  unless File.exist?("examples/build/assets")
    FileUtils.ln_s("../../assets", "examples/build/assets")
  end

  Dir.glob("examples/*.cr").each do |path|
    full_cmd = %'#{cmd} #{flags.join(" ")} "#{path}"'
    puts full_cmd
    system full_cmd
  end
else
  FileUtils.rm_rf("examples/build")
end
