module Filtering
  class Match < Filtering::Filter
    def initialize(*args)
      super(args)
      
      if args.size == 1
        @value = args[0]
      elsif args.size == 2
        @relations = args[0]
        @pattern = args[1]
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
      
    end
    
    def prepare(items, server)
      if(@relations.to_a.empty?)
        return
      end
      filter = build_query_filter(items)
      filter.relation_regex(@relations, @pattern)
      @filtered_items = Set.new(filter.eval)
    end
    
    def filter(item)
      if(@relations.to_a.empty?)
        false
      end
      
      !@filtered_items.include? item
    end
    
    def expression
      relation_exp = ""
      relation_exp = "[" << @relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]" if(@relations)
      
      "match(#{relation_exp}, #{@pattern.to_s})"
    end
  end
  
  def self.match(args)
    if args[:values].nil?
      raise "MISSING VALUES FOR FILTER!"
    end
    self.add_filter(Match.new(args[:relations], args[:values]))
    self
  end
end