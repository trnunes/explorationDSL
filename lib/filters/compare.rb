module Filtering
  class Compare < Filtering::Filter
    
    def initialize(args={})
      super(args)
      @relations = args[:relations]
      @connector = args[:connector]
      @connector ||= "AND"
      @restrictions = args[:restrictions]
    end
    
    # def eval(set)
    #   build_query_filter(set).compare(@relations, @operator, @value)
    #   super(set.extension_copy, set)
    # end
    def prepare(items, server)
      filter = build_query_filter(items)

      if(@connector == "AND")
        @restrictions.each do |restriction|
          operator = restriction[0]
          value = restriction[1]
          filter.compare(@relations, operator, value)
        end
      else
        filter.union do |u|
          @restrictions.each do |restriction|
            operator = restriction[0]
            value = restriction[1]
            u.compare(@relations, operator, value)
          end
        end            
      end
      @filtered_items = Set.new(filter.eval)
    end
    
    def filter(item)
      !@filtered_items.include? item
    end
    
    def expression
      relation_exp = ""
      relation_exp = "[" << @relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]"
      
      "compare(#{relation_exp}, operator: #{@operator.to_s}, value: #{@value.to_s})"
    end
  end
  
  
  
  def self.compare(args)
    if args[:relations].nil?
      raise "MISSING RELATIONS FOR FILTER!"
    end
    if args[:restrictions].nil?
      raise "MISSING VALUE FOR FILTER!"
    end
    self.add_filter(Compare.new(args))
    self
  end
end
