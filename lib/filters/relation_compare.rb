module Filtering
  class RelationCompare < Filtering::Filter
    
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
    def prepare(items, server, args)
      offset = args[:out_offset] || 0
      limit = args[:out_limit] || 0
      filter = build_query_filter(items, {offset: offset, limit: limit})

      if(@connector == "AND")
        @restrictions.each do |restriction|
          operator = restriction[0]
          value = restriction[1]

          filter.compare(@relations.first, operator, value)
        end
      else
        filter.union do |u|
          @restrictions.each do |restriction|
            operator = restriction[0]
            value = restriction[1]
            u.compare(@relations.first, operator, value)
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

      
      relation_exp = @relations.map{|r| r.text}.join(", ")
      
      restrictions_exp = @restrictions.map{|r| r[0] + " " + r[1].text}.join( " " + @connector + " ")
      "#{relation_exp}: #{restrictions_exp}" 
    end
  end
  
  
  
  def self.relation_compare(args)
    if args[:relations].nil?
      raise "MISSING RELATIONS FOR FILTER!"
    end
    if args[:restrictions].nil?
      raise "MISSING VALUE FOR FILTER!"
    end
    self.add_filter(RelationCompare.new(args))
    self
  end
end
