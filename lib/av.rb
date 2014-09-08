require "av/version"
require "av/exceptions"
require "av/cli"
require "av/commands/ffmpeg"
require "av/commands/avconv"
require "cocaine"

module Av
  extend self
  
  def cli
    ::Av::Cli.new
  end
  
  def quiet
    return @quiet if @quiet
    true
  end
  
  def run line, codes = [0]
    Av.log("Running command: #{line}")
    begin
      Cocaine::CommandLine.new(line, "", expected_outcodes: codes).run
    rescue Cocaine::ExitStatusError => e
      raise Av::CommandError, "error while running command #{line}: #{e}"
    end
  end
  
  def log message
    puts "[AV] #{message}"
  end
  
  def detect_command(command)
    command = "if command -v #{command} 2>/dev/null; then echo \"true\"; else echo \"false\"; fi"
    result = Av.run(command)
    case result
      when /true/
        return true
      when /false/
        return false
    end
  end
end