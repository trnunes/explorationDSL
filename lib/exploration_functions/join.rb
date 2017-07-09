module Explorable
  class Join < Explorable::Operation
    
    def eval_set(index_entries)
      start_time = Time.now
      source_index_entries = index_entries
      target_index_entries = [@args[:target].index]
      result_entries = []
      while(!source_index_entries.empty? || !target_index_entries.empty?)
        source_intersection = Set.new
        target_intersection = Set.new

        source_index_entries.each do |entry1|
          target_index_entries.each do |entry2|
            if(entry1.indexing_item == entry2.indexing_item)
              source_intersection << entry1
              target_intersection << entry2
              if(!(entry1.indexed_items.empty? && entry2.indexed_items.empty?))
                join_items(entry1, entry2)
              end
            end
          end
        end
        entries_to_remove = source_index_entries.to_a - source_intersection.to_a
        entries_to_remove.each{|entry| entry.parent.delete_child(entry)}
        source_index_entries = source_intersection.map{|entry| entry.children}.flatten
        target_index_entries = target_intersection.map{|entry| entry.children}.flatten
      end
      # binding.pry
      finish_time = Time.now
      puts "EXECUTED Join: " << (finish_time - start_time).to_s
    end
    
    def join_items(entry1, entry2)
      joined_items = entry1.indexed_items + entry2.indexed_items
      if(entry1.indexed_items[0].class != Xpair::Literal && entry2.indexed_items[0].class != Xpair::Literal)
        joined_items = Set.new(joined_items)
      end
      entry1.indexed_items = joined_items
    end
    
    def v_expression
      "Join(#{@args[:target].title})"
    end
    def expression
      "#{@args[:input].id}.join(#{@args[:target].title})"
    end
    
  end
  
  def join(target, args={})
    args = {target: target}    
    execute_exploration_operation(Join, args)
  end
  
  def v_join(target, args={})
    args = {target: target}    
    execute_visualization_operation(Join, args)
  end
end