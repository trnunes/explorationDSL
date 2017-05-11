module Mapping
  class Count
    include Mapping::Aggregator
  
    def initialize()
      super("count")
      init()
    end
    
    def init(options = {})
      @aggregation = Xpair::Literal.new(0)
    end
    
    def map(item)
      @aggregation.value += 1
    end
    
    
    def expression
      "count"
    end
  end

  def self.count  
    return Count.new()
  end
end