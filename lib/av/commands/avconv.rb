require 'av/commands/base'

module Av
  module Commands
    class Avconv < Base
      def initialize
        @command_name = "avconv"
        @default_params = %Q(-loglevel "quiet") if Av.quiet
      end
      
      def input_concat list
        @input_params << "concat:#{list.join('\|')}"
      end
    end
  end
end
