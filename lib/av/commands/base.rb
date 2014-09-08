require 'tmpdir'

module Av
  module Commands
    # Common features across commands
    class Base
      attr_accessor :command_name
      attr_accessor :input_params
      attr_accessor :output_params
      attr_accessor :default_params

      attr_accessor :source
      attr_accessor :destination
      
      def initialize
        reset_input_filters
        reset_output_filters
        reset_default_filters
      end
      
      def add_source src
        @source = src
      end
      
      def add_destination dest
        @destination = dest
      end
      
      def reset_input_filters
        @input_params = []
      end
      
      def reset_output_filters
        @output_params = []
      end
      
      def reset_default_filters
        @output_params = []
      end
      
      def add_input_filters hash
        hash.each do |k,v|
          @input_params << "-#{k} #{v}"
        end
        self
      end
      
      def add_output_filters hash
        hash.each do |k,v|
          @output_params << "-#{k} #{v}"
        end
        self
      end
      
      def command_line
        raise Av::CommandError if (@source.nil? && @destination.nil?) || @command_name.nil?

        parameters = []
        parameters << @command_name
        parameters << @default_params if @default_params
        if @input_params
          parameters << @input_params.join(' ')
        end
        parameters << %Q(-i "#{@source}") if @source
        if @output_params
          parameters << @output_params.join(' ')
        end
        parameters << %Q(-y "#{@destination}") if @destination
        parameters.flatten.compact.join(" ").strip.squeeze(" ")
      end
    
      def run
        Av.run(command_line)
      end
      
      def identify path
        meta = {}
        command = %Q(#{@command_name} -i "#{File.expand_path(path)}" 2>&1)
        out = Av.run(command, [0,1])
        # rescue Av::CommandError
        #   # Do nothing, we know ffmpeg/avconv will complain with:
        #   # "At least one output file must be specified"
        # end
        out.split("\n").each do |line|
          if line =~ /(([\d\.]*)\s.?)fps,/
            meta[:fps] = $1.to_i
          end
          # Matching lines like:
          # Video: h264, yuvj420p, 640x480 [PAR 72:72 DAR 4:3], 10301 kb/s, 30 fps, 30 tbr, 600 tbn, 600 tbc
          if line =~ /Video:(.*)/
             v = $1.to_s
             size = v.match(/\d{3,5}x\d{3,5}/).to_s
             meta[:size] = size
             meta[:aspect] = size.split('x').first.to_f / size.split('x').last.to_f
           end
          # Matching Duration: 00:01:31.66, start: 0.000000, bitrate: 10404 kb/s
          if line =~ /Duration:(\s.?(\d*):(\d*):(\d*\.\d*))/
            meta[:length] = $2.to_s + ":" + $3.to_s + ":" + $4.to_s
          end
          if line =~ /rotate\s*:\s(\d*)/
            meta[:rotate] = $1.to_i
          end
        end
        meta
      end
    end  
  end
end
