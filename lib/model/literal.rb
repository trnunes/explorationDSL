module Xpair
  class Literal
    include Xpair::Graph
    include Indexable
    attr_accessor :value, :datatype, :index, :entry, :parents
    
    def initialize(value, datatype=nil)
      @datatype = datatype
      @value = value
      @index = Indexing::Entry.new('root')
      @entry = Indexing::Entry.new('root')
      @parents = []
    end
    
    def clone
      cloned_item = self.class.new(@value, @datatype)
      cloned_item.index = @index.copy
      cloned_item
    end
    
    def shallow_clone
      self.class.new(@value, @datatype)
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