module Av
  class ParamHash < Hash
    def to_s
      line = []
      self.each do |group|
        line << "-#{group.join(' ')}"
      end
      line.join(' ')
    end
  end
end