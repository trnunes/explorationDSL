module Filtering
  class Compare < Filtering::Filter
    
    def initialize(args={})
      super(args)
      
      @connector = args[:connector]
      @connector ||= "AND"
      @restrictions = args[:restrictions]
    end
    
    # def eval(set)
    #   build_query_filter(set).compare(@relations, @operator, @value)
    #   super(set.extension_copy, set)
    # end
    def prepare(items, server)
      
    end
    
    def filter(item)
      if(@connector == "AND")
        result = true
      else
        result = false
      end
      
      @restrictions.each do |r|
        if(@connector == "AND")
          result = result && r.evaluate(item)
        else
          result = result || r.evaluate(item)
        end
      end
      !result
    end
    
    def expression
      connector = @connector || "AND" 
      relation_exp = ""
      relation_exp = @restrictions.map{|r| r.expression}.join(" " + connector + " ")
      relation_exp
    end
  end
  
  
  
  def self.compare(args)
    if args[:restrictions].nil?
      raise "MISSING VALUE FOR FILTER!"
    end
    self.add_filter(Compare.new(args))
    self
  end
end
