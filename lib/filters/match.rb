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
    
    def eval(set)
      extension = set.extension_copy
      
      if(@relations.nil?)
        set.each_item.select{|item| item.to_s.match(/#{@pattern}/).nil?}.each do |removed_item|        
          extension.delete(removed_item) 
        end          
      else        
        build_query_filter(set).relation_regex(@relations, @pattern)
      end
      super(extension, set)
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