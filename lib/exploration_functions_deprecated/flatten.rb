module Explorable
  class Flatten < Explorable::Operation
    
    def eval_set(index_entries)
      input_set = @args[:input]
      start_time = Time.now
      index_entries.first.children = []
      
      if(@args[:position] == "domain")
        index_entries.first.indexed_items = input_set.each_domain
      else
        index_entries.first.indexed_items = input_set.each_item
      end
      are_literals = index_entries.first.indexed_items[0].is_a?(Xpair::Literal)
      if(!are_literals)
        index_entries.first.indexed_items = Set.new(index_entries.first.indexed_items).to_a
      end
      
      
      finish_time = Time.now
      puts "EXECUTED FLATTEN: " << (finish_time - start_time).to_s
    end
    
    def v_expression
      "Flatten()"
    end
    
    def expression
      position = @args[:position] || "image"
      "#{@args[:input].id}.flatten(#{position})"
    end
  end
  
  
  def flatten(args = {})
    execute_exploration_operation(Flatten, args)
  end
  
  def v_flatten(args = {})
    execute_visualization_operation(Flatten, args)
  end
  
end