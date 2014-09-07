require "av/version"
require "av/exceptions"
require "cocaine"
require "av/commands/ffmpeg"
require "av/commands/avconv"

module Av
  extend self
  
  def cli
    return @cli if @cli
    @cli = load_av_library
    @cli
  end
  
  def quiet
    return @quiet if @quiet
    true
  end
  
  def run line
    Av.log("Running command: #{line}")
    begin
      Cocaine::CommandLine.new(line).run
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
  
  def load_av_library
    found = []
    found << 'ffmpeg' if detect_command('ffmpeg')
    found << 'avconv' if detect_command('avprobe')
    Av.log("Found: #{found.inspect}")
    if found.empty?
      raise Av::UnableToDetect, "Unable to detect any supported library"
    else
      found.each do |library|
        @cli = Object.const_get('Av').const_get('Commands').const_get(library.capitalize).new
      end
    end
    @cli
  end
end