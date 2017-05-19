module Explorable
  class Union < Explorable::Operation
    
    def eval_set(index_entries)
      start_time = Time.now
      source_index_entries = index_entries
      target_index_entries = [@args[:target].index]
      
      while(!source_index_entries.empty? && !target_index_entries.empty?)
        source_children = []
        target_children = []
        entries_to_be_added = []
        source_index_entries.each do |entry1|
          target_index_entries.each do |entry2|
            if(entry1.indexing_item == entry2.indexing_item)
              entry1.indexed_items = entry1.indexed_items + entry2.indexed_items
            else
              entries_to_be_added << entry2
            end
          end
          source_children += entry1.children
          target_children = target_index_entries.map{|entry| entry.children}.flatten
        end
        entries_to_be_added.each{|entry| source_index_entries.push(entry.copy)}
        source_index_entries = source_children
        target_index_entries = target_children
      end

      finish_time = Time.now
      puts "EXECUTED DIFF: " << (finish_time - start_time).to_s
    end
    
    def expression
      "union(#{@args[:input].id}, #{@args[:target].id})"
    end
  end
  
  def union(target, args={})
    args = {target: target}    
    execute_operation(Union, args)
  end
end