# frozen_string_literal: true

module Av
  class Cli
    attr_accessor :command

    def initialize(options)
      @command = ::Av::Ffmpeg.new(options)
    end

    protected

    def method_missing(name, *args, &block)
      @command.send(name, *args, &block)
    end
  end
end
