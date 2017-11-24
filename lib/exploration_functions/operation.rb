module Explorable
  @@cache = {}
  @@use_cache = true
  @@visualization_session = Xpair::Session.new
  @@exploration_session = Xpair::Session.new
  
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
  
    def initialize(args = {})
      @mappings = {}
      @args = args
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
    
    def eval_root_set(xset)
    end
    
    def eval_set(index_entries)

      entries_to_remove = []
      new_indexed_items = []
      literal_results = false
      
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
            


            next if(delayed_result? && !(item == index_entry.indexed_items.last))
            next if(partial_results.nil?)
            
            partial_results = [partial_results] if !partial_results.respond_to?(:each)
            if !partial_results.first.is_a?(Xpair::Literal)
              @result_set = Set.new(@result_set)
            end
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
    
    def execute(offset = 0, limit = 20, items_to_filter = [])
      items = []
      input_set = @args[:input]

      if(!input_set.empty?)
        @args[:out_offset] = offset
        @args[:out_limit] = limit
        @args[:items_to_filter] = items_to_filter
        self.prepare(@args)
        input_index_structure_copy = input_set.index.copy

        if input_set.root?

          input_index_structure_copy.indexed_items = self.eval_root_set(input_set)
          return 
        else
          
          self.eval_set([input_index_structure_copy])          
        end

      end
      input_index_structure_copy
    end
    
    def create_result_set()
      
      result_set = Xset.new(SecureRandom.uuid, self.expression, self.v_expression)

      input_set = @args[:input]
      # if(!input_set.empty?)
      #   result_index = self.execute()
      #   result_set.index = result_index
      # end
     result_set.mappings = @mappings
     result_set.resulted_from = input_set
     result_set.server = input_set.server
     result_set.intention = self
     result_set
   end
   
   def get_result_set()
     if(Explorable.use_cache?)
       cached_result = Explorable.get_from_cache(self.expression)
       result_set = cached_result
       if(!cached_result)
         result_set = self.create_result_set()
         Explorable.cache(result_set)
       end
     else
       result_set = self.create_result_set()
     end
     result_set.save
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
    operation_klass.new(args).get_result_set()
    
  end
  
  def execute_visualization_operation(operation_klass, args)

    rs = execute_operation(operation_klass, args)
    rs.mappings = @mappings
    Explorable.visualization_session.add_set(rs)
    rs
  end
  
end