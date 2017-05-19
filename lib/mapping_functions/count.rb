module Mapping
  class Count
    include Mapping::Aggregator
  
    def initialize(options = {})
      super("count", options)
    end
    
    def prepare(options = {})
      @aggregated_value = Xpair::Literal.new(0)
    end
    
    def map(item)
      @aggregated_value.value += 1
      @aggregated_value
    end
    
    def expression
      "count"
    end
  end

  def self.count(options = {})
    return Count.new(options)
  end
end