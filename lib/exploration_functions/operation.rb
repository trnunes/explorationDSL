module Explorable
  @@cache = {}
  @@use_cache = true
  @@visualization_session = Xpair::Session.new
  @@exploration_session = Xpair::Session.new
  @@query_set_map = {}
  
  def self.put_query(set_id, query)
    @@query_set_map[set_id] = query
  end
  
  def self.get_query(set_id)
    @@query_set_map[set_id]
  end
  
  def self.set_current_session(session)
    @@exploration_session = session
  end
    
  def self.exploration_session
    @@exploration_session
  end
  
  def self.visualization_session
    @@visualization_session
  end

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
  
    def initialize(*args)
      @mappings = {}
    end
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

      entries_to_remove = []
      new_indexed_items = []
      
      index_entries.each do |index_entry|
        new_indexed_items = []
        if(index_entry.children.empty?)

          @result_set = []
          self.prepare(@args)
          
          index_entry.indexed_items.each do |item|

            

            partial_results = eval_item(item)
            if partial_results.respond_to?(:each)
              @mappings[item] = Set.new partial_results.dup
            else
              @mappings[item] = Set.new([partial_results].compact)
            end
            
            # binding.pry

            next if(delayed_result? && !(item == index_entry.indexed_items.last))
            next if(partial_results.nil?)
            
            partial_results = [partial_results] if !partial_results.respond_to?(:each)
            @result_set += partial_results

          end

          @result_set.each do |result_item|
            is_indexed_result = !result_item.parents.empty?

            if(is_indexed_result)
              entry = nil
              result_item.parents.each do |parent|


                entry = Indexing.find_entry(index_entry.children, parent)
                if(!entry)
                  entry = Indexing::Entry.new(parent.clone)

                  index_entry.add_child entry
                end
                entry << result_item


                
              end
              result_item.parents = []
            else
              
              new_indexed_items << result_item


            end
          end

          
          if(new_indexed_items.empty?)
            entries_to_remove << index_entry
          else
            index_entry.indexed_items = new_indexed_items


          end
        else


          index_entry.indexed_items = []


          eval_set(index_entry.children)
        end
        # index_entry.indexed_items = []


      end

      entries_to_remove.each{|entry| remove_index_entry(index_entries, entry)}
      puts "------------FINISHED EVAL SET IN OPERATION------------------"
    end
    
    def remove_index_entry(index_entries, entry_to_remove)
      entry_to_remove.indexed_items = []
      index_entries.delete(entry_to_remove)
      parent = entry_to_remove

      # parent.children.delete(entry_to_remove)

      while(!parent.nil?)

        if (parent.children.empty? && parent.indexed_items.empty? && parent.indexing_item != "root")
          
          parent.parent.delete_child(parent)
        end
        parent = parent.parent
      end
    end
    def eval_item(item)
    end
    
    def queriable?
      false
    end

    def execute(args={})
      @args = args
      result_set = Xset.new(SecureRandom.uuid, self.expression, self.v_expression)
      result_set.intention = self
      input_set = @args[:input]
      input_set.save

      # binding.pry
      if(Explorable.use_cache?)
        cached_result = Explorable.get_from_cache(self.expression)
        if(cached_result)
          result_set = Explorable.get_from_cache(self.expression)

        else
          if(!@args[:input].empty?) 
            input_set = @args[:input]

            index = input_set.index.copy

            self.eval_set([index])
            result_set.index = index
            # binding.pry
          end
          Explorable.cache(result_set)
          
        end
      else

        if(!@args[:input].empty?)         

          input_set = @args[:input]
          self.prepare(@args)
          index = input_set.index.copy
          self.eval_set([index])
          result_set.index = index
          
          
        end
      end
      result_set.mappings = @mappings
      result_set.resulted_from = input_set
      result_set.server = input_set.server
      if queriable?
        Explorable.put_query(result_set.id, input_set.server.last_query)
      end
      
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
  
  def execute_exploration_operation(operation_klass, args)
   
    rs = execute_operation(operation_klass, args)
   
    Explorable.exploration_session.add_set(rs)
    rs
  end
  
  def execute_operation(operation_klass, args)

    args[:input] = self
    operation_klass.new.execute args
  end
  
  def execute_visualization_operation(operation_klass, args)

    rs = execute_operation(operation_klass, args)
    rs.mappings = @mappings
    Explorable.visualization_session.add_set(rs)
    rs
  end
  
end