
module Filtering
  class Equals < Filtering::Filter
    def initialize(*args)
      super(args)
      
      if args.size == 1
        @value = args[0]
      elsif args.size == 2
        @relations = args[0]
        @value = args[1]
      elsif args.size == 3
        @relations = args[0]
        @value = args[1]
        @connector = args[2]
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
    end
    
    def prepare(items, server)
      if(@relations.to_a.empty?)
        return
      end
      filter = build_query_filter(items)
      
      if(@value.respond_to? :each)
        if(@connector == "AND")
          @value.each do |v|
            filter.relation_equals(@relations, v)
          end
        else
          filter.union do |u|
            @value.each do |v|
              u.relation_equals(@relations, v)
            end
          end            
        end
          
      else
        filter.relation_equals(@relations, @value)
      end
      @filtered_items = Set.new(filter.eval)
    end
    
    def filter(item)
      if(@relations.to_a.empty?)
        false
      end

      !@filtered_items.include?(item)
    end
    
    def expression
      relation_exp = ""

      relation_exp = "[" << @relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]" if(@relations)
      
      values_exp = ""
      if(@value)
        if(!@value.respond_to? :each)
          @value = [@value]
        end
        values_exp = "[" << @value.map{|r| r.to_s}.join(",") << "]" 
      end
      
      
      "equals(#{relation_exp}, #{values_exp}, #{@connector.to_s})"
      
    end  
  end
  
  def self.equals(args)
    if args[:values].nil?
      raise "MISSING VALUES FOR FILTER!"
    end
    args[:connector] ||= "AND"
    self.add_filter(Equals.new(args[:relations], args[:values], args[:connector]))
    self
  end
end