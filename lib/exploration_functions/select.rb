module Explorable
  class Select < Explorable::Operation
    
    def prepare(args)
    end
    
    def eval_set(index_entries)
      input_set = @args[:input]
      items_to_search = @args[:items]
      start_time = Time.now
      result_items = Set.new
      index_entries.each do |entry|
        items_to_search.each do |item|
          # binding.pry
          retrieved_item = search_item(entry, item)
          result_items << retrieved_item.clone if(retrieved_item)
          # binding.pry
        end
      end
      index_entries.first.children = []
      index_entries.first.indexed_items = result_items.to_a

      finish_time = Time.now
    end
    
    def eval_item(item)
    
    end
    
    def search_item(index, item)
      # binding.pry
      if index.indexing_item == item
        return index.indexing_item
      else
        indexed_item = index.indexed_items.select{|indexed_item| indexed_item == item}.first
        puts "tried select"
        # binding.pry
        if(indexed_item)
          return indexed_item
        else
          index.children.each do |child|
            result_item = search_item(child, item)
            return result_item if(result_item)
              
          end
        end
      end
      return nil
    end
    def v_expression
      "Select(#{@args[:items].map{|item| item.text}})"
    end
    
    def expression
      "#{@args[:input].id}.select(#{@args[:items].map{|item| item.text}})"
    end
  end
  
  def select_items(items)
    args = {}
    args[:items] = items
    execute_exploration_operation(Select, args)
  end
  
  def v_select_items(items)
    args = {}
    args[:items] = items
    execute_visualization_operation(Select, args)
  end
  
end