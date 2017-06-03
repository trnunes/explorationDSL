module Mapping
  class Sum
    include Mapping::Aggregator
    def initialize(options = {})
      super("sum", options)
    end
    
    def prepare(options = {})
      @sum = Xpair::Literal.new(0)
    end
    
    def map(item)
      # binding.pry
      if(!item.is_a? Xpair::Literal)
        raise "Mapping function should receive only literals as arugments! (#{item.inspect})"
      end
      @sum.value += item.value.to_f
      @sum
      # binding.pry
    end
    
    def expression
      "sum"
    end
  end

  def self.sum(options = {})
    return Sum.new(options)
  end
end
