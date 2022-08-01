# frozen_string_literal: true

module Av
  class CommandError < StandardError; end
  class InvalidInputFile < StandardError; end
  class InvalidOutputFile < StandardError; end
  class InvalidFilterParameter < StandardError; end
  class FilterNotImplemented < StandardError; end
end
