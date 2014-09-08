require 'av/commands/base'
require 'tempfile'

module Av
  module Commands
    class Ffmpeg < Base
      
      def initialize
        super
        @command_name = "ffmpeg"
      end
      
      def filter_concat list
        index_file = Tempfile.new('ffmpeg-concat')
        File.open(index_file, 'w') do |file|
          list.each do |item|
            file.write("file '#{item}'\n")
          end
        end
        @input_params << "concat -i #{index_file.path}"
        self
      end
      
      def filter_volume vol
        @input_params << "-af volume=#{vol}"
        self
      end
    end
  end
end
