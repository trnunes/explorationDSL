module Filtering
  class InRange < Filtering::Filter
    
    def initialize(*args)
      super(args)
      
     if args.size == 3
        @relations = args[0]
        @min = args[1]
        @max = args[2]
      else
        raise "Invalid number of arguments. Expected: 3; Received: #{args.size}"
      end      
    end
    
    def eval(set)
      build_query_filter(set).filter_by_range(@relations, @min, @max)
      super(set.extension_copy, set)
    end
    
    def expression
      relation_exp = ""
      relation_exp = "[" << @relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]" 
      
      "inRange(#{relation_exp}, min: #{@min.to_s}, max: #{@max.to_s})"
    end
  end
  
  def self.in_range(args)
    if args[:relations].nil?
      raise "MISSING RELATIONS FOR FILTER!"
    end
    if args[:min].nil?
      raise "MISSING LOWER BOUND VALUE FOR FILTER!"
    end
    if args[:max].nil?
      raise "MISSING UPPER BOUND VALUE FOR FILTER!"
    end
    self.add_filter(InRange.new(args[:relations], args[:min], args[:max]))
    self
  end
end
