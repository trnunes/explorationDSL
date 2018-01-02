module Explorable
  class Intersection < Explorable::Operation
    
    def eval_set(index_entries)
      
      
      start_time = Time.now
      source_index_entries = index_entries
      target_index_entries = [@args[:target].index]
      
      while(!source_index_entries.empty? && !target_index_entries.empty?)
        source_children = []
        target_children = []
        source_index_entries.each do |entry1|
          target_index_entries.each do |entry2|
            if(entry1.indexing_item == entry2.indexing_item)
              entry1.indexed_items = entry1.indexed_items & entry2.indexed_items
            end
          end
          source_children += entry1.children
          target_children = target_index_entries.map{|entry| entry.children}.flatten
        end
        source_index_entries = source_children
        target_index_entries = target_children
      end
      finish_time = Time.now
      puts "EXECUTED DIFF: " << (finish_time - start_time).to_s
    end
    
    def v_expression
      "Intersect(#{@args[:target].title})"
    end
    
    def expression
      "#{@args[:input].id}.intersect(#{@args[:target].id})"
    end
    
  end
  
  def intersect(target)
    args = {target: target}
    execute_exploration_operation(Intersection, args)
  end
end