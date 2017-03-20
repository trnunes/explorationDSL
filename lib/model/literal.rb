module Xpair
  class Literal
    include Xpair::Graph
    attr_accessor :value
    def initialize(value)
      @value = value
    end
  
    def eql?(obj)
      self.class == obj.class && @value.to_s == obj.value.to_s
    end
  
    def hash
      @value.to_s.hash
    end
  
    def to_s
      @value.to_s
    end
    alias == eql?
  end
end