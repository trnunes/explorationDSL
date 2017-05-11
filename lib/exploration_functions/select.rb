module Explorable
  class Select < Explorable::Operation
    
    def eval
      
      start_time = Time.now
      result_items = Set.new
      @args[:input].search_items(@args[:items], result_items)
      finish_time = Time.now

      return result_items.map{|i| [i, {}]}.to_h
    end
    
    def expression
      "select(#{@args[:input].id}, #{@args[:items].to_s})"
    end
  end
  
  def select_items(items)
    args = {}
    args[:items] = items
    execute_operation(Select, args)
  end
end