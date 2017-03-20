module Mapping
  class Count < Function
  
    def initialize()
      super("count")
      @count = 0
      @mapped_items = []
    end
    
    def map(xset)
      @count = 0
      xset.each do |item|
        @count += 1
      end
      mappings = {Xpair::Literal.new(@count) => {}}
      result_index[xset] = {Xpair::Literal.new(@count)=>{}}

      [mappings, result_index]
    end
  end

  def self.count
    count = 0    
    return Count.new()
  end
end