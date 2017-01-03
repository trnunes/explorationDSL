module Filtering
  class InRange < Filtering::Filter
    
    def initialize(*args)
      super(args)
      
     if args.size == 3
        @relation = args[0]
        @min = args[1]
        @max = args[2]
      else
        raise "Invalid number of arguments. Expected: 3; Received: #{args.size}"
      end      
    end
    
    def eval(set)
      build_query_filter(set).filter_by_range(@relation, @min, @max)
      super(set.extension_copy, set)
    end
    
    def expression
      "InRange"
    end
  end
  
  def self.in_range(relation, min, max)
    self.add_filter(InRange.new(relation, min, max))
    self
  end
end
