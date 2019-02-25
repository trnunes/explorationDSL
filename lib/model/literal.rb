module Xplain
  class Literal
  
    attr_accessor :value, :datatype, :parent, :children
  
    def initialize(value, type=nil)
      @value = value
      @datatype = type
      @children = []
    end
    
    def <=>(other_literal)
      if other_literal.value.class == self.value.class
        other_literal.value <=> self.value
      else
        other_literal.text <=> self.text
      end
    end

    def copy
      self_copy = Literal.new(@value, @datatype)
      self_copy
    end
    
    def eql?(literal)
      literal.is_a?(self.class) && literal.value == @value
    end
    
    def hash
      @value.hash
    end
    
    def numeric?
      return true if self.text =~ /\A\d+\Z/
      true if Float(self.value) rescue false
    end

    alias == eql?
    
    def text
      @value.to_s
    end    
  
    def to_s
      "Literal: " + @value.to_s
    end
  
    def inspect
      to_s
    end
  end
end