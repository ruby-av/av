require 'av/commands/base'

module Av
  module Commands
    class Ffmpeg < Base
      def initialize
        @command_name = "ffmpeg"
      end
      
      def input_concat list
        index_file = TempFile.new
        File.open(index_file, 'w') do |file|
          list.each do |item|
            file.write("file '#{item}'\n")
          end
        end
        @input_params << "concat -i #{index_file}"
      end
    end
  end
end
