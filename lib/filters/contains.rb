module Filtering
  class Contains < Filtering::Filter
    
    def initialize(*args)
      super(args)
      
      if args.size == 2
        @relations = args[0]
        @values = args[1]
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end
    end
    
    def prepare(items, server)
      count = 0
      f = build_query_filter(items)

      f.union do |u|
        @values.each do |value|
          u.relation_equals(@relations, value) 
        end
      end
      @filtered_items = Set.new(f.eval)
    end
    
    def filter(item)
      @filtered_items.include?(item)
    end
    
    def expression
      relation_exp = ""
      relation_exp = "[" << @relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]" if(@relations)
      
      values_exp = ""
      if(@values)
        if(!@values.respond_to? :each)
          @values = [@values]
        end
        values_exp = "[" << @value.map{|r| r.to_s}.join(",") << "]" 
      end
      

      
      "contains(#{relation_exp}, #{values_exp})"
      
    end
  end
  
  def self.contains_one(args)
    if args[:values].nil?
      raise "MISSING VALUES FOR FILTER!"
    end
    self.add_filter(Contains.new(args[:relations], args[:values]))
    self
  end
end