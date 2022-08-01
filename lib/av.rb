# frozen_string_literal: true

require 'av/version'
require 'av/exceptions'
require 'av/logger'
require 'av/cli'
require 'av/param_hash'
require 'av/ffmpeg'
require 'terrapin'
require 'av/engine' if defined?(Rails)

module Av
  extend self
  extend Logger

  def options
    @options ||= {
      log: true,
      quiet: true
    }
  end

  def cli(options = {})
    @options = options unless options.empty?
    ::Av::Cli.new(options)
  end

  def run(command, codes = [0])
    ::Av.log("Running command: #{command}")
    begin
      Terrapin::CommandLine.new(command, '', expected_outcodes: codes).run
    rescue Terrapin::ExitStatusError => e
      raise(Av::CommandError, "Error while running command #{command}: #{e}")
    end
  end
end
