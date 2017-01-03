module Filtering
  class Contains < Filtering::Filter
    
    def initialize(*args)
      super(args)
      
      if args.size == 2
        @relation = args[0]
        @values = args[1]
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
    end
    
    def eval(set)
      count = 0
      f = build_query_filter(set)
      
      f.union do |u|
        @values.each do |value|
          u.relation_equals(@relation, value) 
        end
      end
      
      
      
      super(set.extension_copy, set)      
    end
    
    def expression
      ".contains_one"
    end
  end
  
  def self.contains_one(relation, values)
    self.add_filter(Contains.new(relation, values))
    self
  end
end