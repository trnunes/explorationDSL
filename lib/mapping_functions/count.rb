module Mapping
  class Count < Function
  
    def initialize()
      super("count")
      @count = 0
      @mapped_items = []
    end
    
    def map(xset)
      @count = 0
      xset.each_item do |item|
        @count += 1
      end
      if xset.is_a? Xsubset
        mappings = {xset => Xsubset.new(xset.key){|s| s.extension = {Xpair::Literal.new(@count) => {}}}}
      else
        mappings = {xset=>Xpair::Literal.new(@count)}
      end
      
      mappings
    end
  end

  def self.count
    count = 0    
    return Count.new()
  end
end