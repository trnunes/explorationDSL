
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
    
    def eval(set)
      extension = set.extension_copy
      set_copy = Xset.new{|s| s.extension = extension}
      if(@relations.nil?)
          set_copy.each_item.select{|item| !(item.eql?(@value))}.each do |removed_item|
            set_copy.remove_item(removed_item)
          end
          set_copy.extension
      else
        filter = build_query_filter(set)
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
        super(extension, set)
      end
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