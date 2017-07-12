module LocalFilter   
  attr_accessor :filters, :filtered_items, :items_to_filter

  def initialize(items_to_filter)
    @filters = []
    @filtered_items = []
    @items_to_filter = items_to_filter
  end
  
  def compare(relation, comparator_str, value)
    
    comparator = case comparator_str
      
    when "="
      Filtering::Operator.requal(relation, value)
    when "<"
      Filtering::Operator.rless_than(relation, value)
    when ">"
      Filtering::Operator.rgreater_than(relation, value)
    when "<="
      Filtering::Operator.rless_than_equal(relation, value)
    when ">="
      Filtering::Operator.rgreater_than_equal(relation, value)
    else
      raise "Invalid Operator: #{comparator}"
    end
    @filters << comparator
    
  end
  
  


  def union(&block)
    union_filter = LocalORFilter.new
    if block_given?
      yield(union_filter)
    else
      raise "Union block should be passed!"
    end
    @filters << union_filter
  end

  def evaluate(item)
  end
  
  def eval
    filtered_items = []
    @items_to_filter.select do |item|
      if !evaluate(item)
        filtered_items << item
      end
    end
    filtered_items
  end

  class LocalANDFilter
    include LocalFilter
    def evaluate(item)
      filter_item = true
      @filters.each do |f|
        if(f.respond_to? "evaluate")
          filter_item = filter_item && !f.evaluate(item)
        end
      end
      filter_item
    end
    
  end

  class LocalORFilter
    include LocalFilter
    
    def evaluate(item)
      filter_item = false
      @filters.each do |f|
        filter_item = filter_item || !f.evaluate(item)
      end
      filter_item
    end
    
  end
  
end

