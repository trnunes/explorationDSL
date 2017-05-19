module Explorable
  @@cache = {}
  @@use_cache = true

  def self.get_cache
    @@cache
  end
  
  def self.cache(xset)
    @@cache[xset.expression] = xset
  end
  
  def self.get_from_cache(expression)
    @@cache[expression]
  end
  
  def self.use_cache(use_cache_b)
    @@use_cache = use_cache_b
  end
  
  def self.use_cache?
    @@use_cache
  end
  
  
  class Operation  
  
    def update
      execute(@args)
    end
    
    def delayed_result?
      false
    end
    
    def horizontal?
      return false
    end
    
    def prepare(args)
    end
    
    def eval_set(index_entries)
      # binding.pry
      entries_to_remove = []
      index_entries.each do |index_entry|
        
        if(index_entry.children.empty?)
          self.prepare(@args)
          # ##binding.pry
          
          new_indexed_items = []

          index_entry.indexed_items.each do |item|
            puts "item in eval_set"

            result_items = eval_item(item)
            # binding.pry
            next if(delayed_result? && !(item == index_entry.indexed_items.last))
            next if(result_items.nil?)
            
            result_items = [result_items] if !result_items.respond_to?(:each)
            # binding.pry

            result_items.each do |result_item|
              is_indexed_result = !result_item.parents.empty?

              if(is_indexed_result)
                entry = nil
                result_item.parents.each do |parent|
                  puts "BEFORE ADD PARENT"
                  # binding.pry
                  entry = Indexing.find_entry(index_entry.children, parent)
                  if(!entry)
                    entry = Indexing::Entry.new(parent.clone)
                    # binding.pry
                    index_entry.add_child entry
                  end
                  entry << result_item
                  # binding.pry
                  
                end
                result_item.parents = []
              else
                
                new_indexed_items << result_item
                ##binding.pry
              end
            end
          end
          if(new_indexed_items.empty?)
            entries_to_remove << index_entry
          else
            index_entry.indexed_items = new_indexed_items
          end
        else
          puts "NOT EMPTY: " << index_entry.to_s
          # binding.pry
          index_entry.indexed_items = []
          puts "AFTER REMOVE INDEXED ITEMS"
          # binding.pry
          eval_set(index_entry.children)
        end
        # index_entry.indexed_items = []
        puts "AFTER ANALYSIS"
        # binding.pry
      end
      entries_to_remove.each{|entry| remove_index_entry(index_entries, entry)}
    end
    
    def remove_index_entry(index_entries, entry_to_remove)
      entry_to_remove.indexed_items = []
      index_entries.delete(entry_to_remove)
      parent = entry_to_remove

      # parent.children.delete(entry_to_remove)
      # binding.pry
      while(!parent.nil?)
        # binding.pry
        if (parent.children.empty? && parent.indexed_items.empty? && parent.indexing_item != "root")
          
          parent.parent.delete_child(parent)
        end
        parent = parent.parent
      end
    end
    def eval_item(item)
    end

    def execute(args={})
      @args = args
      result_set = Xset.new(SecureRandom.uuid, '')
      input_set = @args[:input]

      # ##binding.pry
      if(Explorable.use_cache?)
        cached_result = Explorable.get_from_cache(self.expression)
        if(cached_result)
          result_set = Explorable.get_from_cache(self.expression)
          puts "FOUND IN CACHE: #{self.expression}"
        else
          if(!@args[:input].empty?) 
            input_set = @args[:input]

            index = input_set.index.copy
            # ##binding.pry
            self.eval_set([index])
            result_set.index = index
          end
          Explorable.cache(result_set)
          
        end
      else
        # ##binding.pry
        if(!@args[:input].empty?)         
          # ##binding.pry
          input_set = @args[:input]
          self.prepare(@args)
          index = input_set.index.copy
          self.eval_set([index])
          result_set.index = index

          
        end
      end
      result_set.resulted_from = input_set
      result_set.server = input_set.server
      result_set
      
    end
    
  
    def dependencies
      @args.values.flatten.select do |arg|
        arg.is_a? Xset
      end
    end
  
    def validate
      return true
    end
  
    def expression
    end
  
    def mount_result_set(mappings)

      result_set = Xset.new do |s|
        s.extension = mappings
        s.intention = self
        s.server = @args[:input].server
        s.resulted_from = @args[:input]
      end    
      @args[:input].generates << result_set
      result_set.save
      return result_set
    end
  end
  
  def execute_operation(operation_klass, args)
    args[:input] = self
    operation_klass.new.execute args
  end
  
end