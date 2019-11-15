module Av
  class Error < StandardError; end
  class UnableToDetect < Error; end
  class CommandError < Error; end
  class InvalidInputFile < Error; end
  class InvalidOutputFile < Error; end
  class InvalidFilterParameter < Error; end
  class FilterNotImplemented < Error; end
end
