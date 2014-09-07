require 'tmpdir'

module Av
  module Commands
    # Common features across commands
    class Base
      attr_accessor :command_name
      attr_accessor :input_params
      attr_accessor :output_params
      attr_accessor :source
      attr_accessor :destination
      attr_accessor :default_params
      
      def add_source src
        @source = src
      end
      
      def add_destination dest
        @destination = dest
      end
      
      def command_line
        raise Av::InvalidInputFile if @source.nil?
        raise Av::InvalidOutputFile if @destination.nil?
        
        parameters = []
        parameters << @command_name
        parameters << @default_params
        if @input_params
          parameters << @input_params.map { |k,v| "-#{k.to_s} #{v} " if !v.nil? && (v.is_a?(Numeric) || !v.empty?) }
        end
        parameters << %Q(-i "#{@source}")
        if @output_params
          parameters << @output_params.map { |k,v| "-#{k.to_s} #{v} " if !v.nil? && (v.is_a?(Numeric) || !v.empty?) }
        end
        parameters << %Q(-y "#{@destination}")
        parameters.flatten.compact.join(" ").strip.squeeze(" ")
      end
    
      def run
        Av.run(command_line)
      end
    end  
  end
end
