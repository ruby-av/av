require 'av/commands/base'

module Av
  module Commands
    class Avconv < Base
      
      def initialize
        super
        @command_name = "avconv"
        @default_params = %Q(-loglevel "quiet") if Av.quiet
      end
      
      def input_concat list
        @input_params << %Q(-i concat:#{list.join('\|')} -c copy)
        self
      end
    end
  end
end
