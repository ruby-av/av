require 'tmpdir'

module Av
  module Commands
    # Common features across commands
    class Base
      attr_accessor :options
      attr_accessor :command_name
      attr_accessor :input_params
      attr_accessor :output_params
      attr_accessor :audio_filters
      attr_accessor :video_filters
      attr_accessor :default_params

      attr_accessor :source
      attr_accessor :destination
      
      def initialize(options = {})
        reset_input_filters
        reset_output_filters
        reset_default_filters
        @options = options
      end
      
      def add_source src
        @source = src
      end
      
      def add_destination dest
        @destination = dest
      end
      
      def reset_input_filters
        @input_params = ParamHash.new
        @audio_filters = ParamHash.new
        @video_filters = ParamHash.new
      end
      
      def reset_output_filters
        @output_params = ParamHash.new
      end
      
      def reset_default_filters
        @default_params = ParamHash.new
      end
      
      def add_input_param hash
        hash.each do |k,v|
          @input_params[k] = [] unless @input_params.has_key?(k)
          @input_params[k] << v
        end
        self
      end
      
      def add_output_param hash
        hash.each do |k,v|
          @output_params[k] = [] unless @output_params.has_key?(k)
          @output_params[k] << v
        end
        self
      end
      
      def run
        raise Av::CommandError if (@source.nil? && @destination.nil?) || @command_name.nil?

        parameters = []
        parameters << @command_name
        parameters << @default_params if @default_params
        if @input_params
          parameters << @input_params.to_s
        end
        parameters << %Q(-i "#{@source}") if @source
        if @output_params
          parameters << @output_params.to_s
        end
        parameters << %Q(-y "#{@destination}") if @destination
        command_line = parameters.flatten.compact.join(" ").strip.squeeze(" ")
        ::Av.run(command_line)
      end
      
      def identify path
        meta = {}
        command = %Q(#{@command_name} -i "#{File.expand_path(path)}" 2>&1)
        out = ::Av.run(command, [0,1])
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
      
      def output_format format
        case format
        when 'jpg', 'jpeg', 'png', 'gif' # Images
          add_output_param 'f', 'image2'
          add_output_param 'vframes', '1'
        when 'webm' # WebM
          add_output_param 'f', 'webm'
          add_output_param 'acodec', 'libvorbis'
          add_output_param 'vcodec', 'libvpx'
        when 'ogv' # Ogg Theora
          add_output_param 'f', 'ogg'
          add_output_param 'acodec', 'libvorbis'
          add_output_param 'vcodec', 'libtheora'
        when 'mp4'
          add_output_param 'acodec', 'aac'
          add_output_param 'strict', 'experimental'
        end
      end
      
      # Children should override the following methods
      def filter_rotate degrees
        raise ::Av::FilterNotImplemented, 'rotate'
      end
    end  
  end
end
