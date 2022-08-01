# frozen_string_literal: true

require 'logger'

module Av
  module Logger
    def log(message)
      logger.info("[AV] #{message}") if options[:log]
    end

    def logger
      @logger ||= ::Logger.new($stdout)
    end

    def logger=(logger)
      @logger = logger
    end
  end
end
