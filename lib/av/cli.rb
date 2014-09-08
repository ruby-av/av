module Av
  class Cli
    attr_accessor :command
    
    def initialize
      found = []
      found << 'ffmpeg' if ::Av.detect_command('ffmpeg')
      found << 'avconv' if ::Av.detect_command('avprobe')
      ::Av.log("Found: #{found.inspect}")
      if found.empty?
        raise Av::UnableToDetect, "Unable to detect any supported library"
      else
        found.each do |library|
          @command = Object.const_get('Av').const_get('Commands').const_get(library.capitalize).new
        end
      end
    end

    protected
      def method_missing name, *args, &block
        @command.send(name, *args, &block)
      end
  end
end