module Explorable
  class Select < Explorable::Operation
    
    def prepare(args)
    end
    
    def eval_set(index_entries)
      input_set = @args[:input]
      items_to_search = @args[:search_items]
      start_time = Time.now
      result_items = Set.new
      index_entries.each do |entry|
        items_to_search.each do |item|
          result_items << search_item(entry, item).clone
        end
      end
      index_entries.first.children = []
      index_entries.first.indexed_items = result_items
      finish_time = Time.now
    end
    
    def eval_item(item)
    
    end
    
    def search_item(index, item)
      if index.indexing_item == item
        return index.indexing_item
      else
        indexed_item = index.indexed_items.get(item)
        if(indexed_item)
          return indexed_item
        else
          index.children.each do |child|
            search_item(child, item)
          end
        end
      end
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