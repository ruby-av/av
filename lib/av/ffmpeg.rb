# frozen_string_literal: true

require 'tmpdir'
require 'tempfile'

module Av
  class Ffmpeg
    attr_accessor :options,
                  :command_name,
                  :input_params,
                  :output_params,
                  :audio_filters,
                  :video_filters,
                  :default_params,
                  :source, :destination

    def initialize(options = {})
      reset_input_filters
      reset_output_filters
      reset_default_filters
      @options = options
      @command_name = 'ffmpeg'
      @default_params['loglevel'] = 'quiet' unless options[:quiet] == false
    end

    def filter_concat(list)
      index_file = Tempfile.new('ffmpeg-concat')
      File.open(index_file, 'w') do |file|
        list.each do |item|
          file.write("file '#{item}'\n")
        end
      end
      add_input_param concat: "-i #{index_file.path}"
      self
    end

    def add_source(src)
      @source = src
    end

    def add_destination(dest)
      # infer format from extension unless format has already been set
      output_format File.extname(dest) if @output_format.nil?
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

    def add_input_param(*param)
      p = parse_param(param)
      @input_params[p[0]] = [] unless @input_params.key?(p[0])
      @input_params[p[0]] << p[1]
      self
    end

    def set_input_params(hash)
      @input_params = hash
    end

    def add_output_param(*param)
      p = parse_param(param)
      @output_params[p[0]] = [] unless @output_params.key?(p[0])
      @output_params[p[0]] << p[1]
      self
    end

    def set_output_params(hash)
      @output_params = hash
    end

    def run
      raise Av::CommandError if (@source.nil? && @destination.nil?) || @command_name.nil?

      parameters = []
      parameters << @command_name
      parameters << @default_params if @default_params
      parameters << @input_params.to_s if @input_params
      parameters << %(-i "#{@source}") if @source
      parameters << @output_params.to_s if @output_params
      parameters << %(-y "#{@destination}") if @destination
      command_line = parameters.flatten.compact.join(' ').strip.squeeze(' ')
      ::Av.run(command_line)
    end

    def identify(path)
      meta = {}
      command = %(#{@command_name} -i "#{File.expand_path(path)}" 2>&1)
      out = ::Av.run(command, [0, 1])
      out = out.force_encoding('UTF-8').encode('UTF-8', invalid: :replace)
      out.split("\n").each do |line|
        meta[:fps] = Regexp.last_match(1).to_i if line =~ /(([\d.]*)\s.?)fps,/

        # Matching lines like:
        # Video: h264, yuvj420p, 640x480 [PAR 72:72 DAR 4:3], 10301 kb/s, 30 fps, 30 tbr, 600 tbn, 600 tbc
        if line =~ /Video:(.*)/
          size = Regexp.last_match(1).to_s.match(/\d{3,5}x\d{3,5}/).to_s
          meta[:size] = size unless size.empty?
          if meta[:size]
            meta[:width], meta[:height] = meta[:size].split('x').map(&:to_i)
            meta[:aspect] = meta[:width].to_f / meta[:height]
          end
        end

        # Matching lines like:
        # Stream #0.0: Audio: libspeex, 8000 Hz, mono, s16
        if line =~ /Audio:(.*)/
          meta[:audio_encode], meta[:audio_bitrate], meta[:audio_channels] = Regexp.last_match(1).to_s.split(',').map(&:strip)
        end

        # Matching lines like:
        # Duration: 00:01:31.66, start: 0.000000, bitrate: 10404 kb/s
        if line =~ /Duration:(\s.?(\d*):(\d*):(\d*\.\d*))/
          meta[:length] =
            "#{Regexp.last_match(2)}:#{Regexp.last_match(3)}:#{Regexp.last_match(4)}"
          meta[:duration] =
            Regexp.last_match(2).to_i * 3600 + Regexp.last_match(3).to_i * 60 + Regexp.last_match(4).to_f
        end

        meta[:rotate] = Regexp.last_match(1).to_i if line =~ /rotate\s*:\s(\d*)/
      end

      if meta.empty?
        ::Av.log "Empty metadata from #{path}. Got the following output: #{out}"
      else
        return meta
      end

      nil
    end

    def output_format(format)
      @output_format = format
      case format.to_s
      when /jpg$/, /jpeg$/, /png$/, /gif$/ # Images
        add_output_param 'f', 'image2'
        add_output_param 'vframes', '1'
      when /webm$/ # WebM
        add_output_param 'f', 'webm'
        add_output_param 'acodec', 'libvorbis'
        add_output_param 'vcodec', 'libvpx'
      when /ogv$/ # Ogg Theora
        add_output_param 'f', 'ogg'
        add_output_param 'acodec', 'libvorbis'
        add_output_param 'vcodec', 'libtheora'
      when /mp4$/
        add_output_param 'acodec', 'aac'
        add_output_param 'strict', 'experimental'
      end
    end

    def filter_rotate(degrees)
      raise ::Av::InvalidFilterParameter unless (degrees % 90).zero?

      case degrees
      when 90
        add_output_param vf: "'transpose=1'"
      when 180
        add_output_param vf: "'vflip,hflip'"
      when 270
        add_output_param vf: "'transpose=2'"
      end

      self
    end

    def filter_volume(vol)
      add_output_param af: "volume=#{vol}"
      self
    end

    def filter_seek(seek)
      add_input_param ss: seek
      self
    end

    def parse_param(param)
      list = []
      case param.count
      when 2
        list = param
      when 1
        case param[0].class.to_s
        when 'Hash'
          list[0], list[1] = param[0].to_a.flatten!
        when 'Array'
          list = param[0]
        end
      end
      list
    end

    def metadata_rotate(degrees)
      add_output_param :'metadata:s:v:0', "rotate=#{degrees}"

      self
    end

    def filter_metadata_rotate(degrees)
      filter_rotate degrees

      if @source
        current_rotate = identify(@source)[:rotate] || 0
      else
        ::Av.log 'Source has not been set - assuming current rotation metadata is 0'
        current_rotate = 0
      end

      metadata_rotate (current_rotate - degrees) % 360

      self
    end
  end
end
