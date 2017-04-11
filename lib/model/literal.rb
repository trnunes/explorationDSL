module Xpair
  class Literal
    include Xpair::Graph
    attr_accessor :value, :datatype
    def initialize(value, datatype=nil)
      @datatype = datatype
      @value = value
    end
    
    def has_datatype?
      !(datatype.nil? || datatype.empty?)
    end
  
    def eql?(obj)
      self.class == obj.class && @value.to_s == obj.value.to_s
    end
  
    def hash
      @value.to_s.hash
    end
    
    def text
      @value.to_s
    end
      
  
    def to_s
      @value.to_s
    end
    alias == eql?
  end
end