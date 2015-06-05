module Av
  class ParamHash < Hash
    def to_s
      line = []
      self.each do |option, value|
        value = value.join(',') if value.is_a?(Array)
        line << "-#{option} #{value}"
      end
      line.join(' ')
    end
  end
end