require "av/version"
require "av/exceptions"
require "av/cli"
require "av/param_hash"
require "av/commands/ffmpeg"
require "av/commands/avconv"
require "cocaine"

module Av
  extend self
  
  def cli(options = {})
    ::Av::Cli.new(options)
  end
  
  def run line, codes = [0]
    ::Av.log("Running command: #{line}")
    begin
      Cocaine::CommandLine.new(line, "", expected_outcodes: codes).run
    rescue Cocaine::ExitStatusError => e
      raise Av::CommandError, "error while running command #{line}: #{e}"
    end
  end
  
  def log message
    puts "[AV] #{message}"
  end
end