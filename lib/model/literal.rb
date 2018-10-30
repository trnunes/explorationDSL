module Xplain
  class Literal
    extend Forwardable
  
    attr_accessor :value, :datatype, :parent, :children
    def_delegators :@children, :<<
  
    def initialize(value, type=nil)
      @value = value
      @datatype = type
      @children = []
    end
  
    def set_parent(parent)
      @parent = parent
    end
  
    def add_child(item)
      @children << item
      item.set_parent(self)
    end
  
    def set_children(children_set)
      @children = children_set
      children_set.each{|c| c.set_parent self}
    end
  
    def copy
      self_copy = Literal.new(@value, @datatype)
      @children.each{|child| self_copy.add_child child.copy}
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