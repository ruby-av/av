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
        @input_params = []
        @output_params = []
        @default_params = []
      end
      
      def add_source src
        @source = src
      end
      
      def add_destination dest
        @destination = dest
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
    end  
  end
end
