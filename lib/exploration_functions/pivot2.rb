module Explorable
  class Pivot < Explorable::Operation
    
    def schema_relations?(relations)
      all_schema = true
      relations.each do |r| 
        if !is_schema?(r)
          all_schema = false
        end
      end
      all_schema
    end
    
    def is_schema?(relation)
      relation.is_a?(Relation) || relation.is_a?(String)
    end
    
    def pivot_mixed_property_path(items, relations)
      mappings = {}
      mappings = items.map{|i| [i, {}]}.to_h
      local_mappings = mappings
      inverse = (@args[:direction] == "backward")
      relations.each do |r|
        if(is_schema?(r))
          partial_mappings = schema_image(items, r, inverse)
          #binding.pry
        else
          partial_mappings = {}
          items.each do |item|
            if inverse
              partial_mappings[item] = r.domain(item)
            else
              partial_mappings[item] = r[item]
            end
            #binding.pry
          end
        end
        
        items = Set.new
    
        if(HashHelper.empty_values?(local_mappings))
          partial_mappings.each do |key, values|
            local_mappings[key] = values
            items += values.keys
          end
          #binding.pry
        else
          local_mappings.each do |local_key, local_values|
            pivot_values = Set.new
            partial_mappings.each do |key, values|
              
              if(local_values.has_key? key)
                pivot_values += values.keys
              end
              #binding.pry
            end
            local_mappings[local_key] = pivot_values.map{|k| [k, {}]}.to_h
            #binding.pry
            items += pivot_values
          end
        end
      end
      mappings = local_mappings
      mappings
    end
    
    def schema_image(items, relation, inverse=false)
      limit = @args[:limit]
      limit ||= items.size
      mappings = {}
      query = @args[:input].server.begin_nav_query do |q|
        items.to_a[0..limit].each do |item|
          q.on(item)
        end
        if inverse
          q.restricted_domain(relation)
        else
          q.restricted_image(relation)
        end
      end
      
      partial_values_set = Set.new
      
      partial_path_results = query.execute
      if(inverse)

        partial_path_results.each do |item, relations_hash|
          relations_hash.each do |relation, values|
            values.each do |value|
              mappings[value] ||= {}
              mappings[value][item] = {}
            end
          end  
        end

      else
        partial_path_results.each do |item, relations_hash|
          mappings[item] = {}

          relations_hash.each do |key, values|
            values.each do |v|
              mappings[item][v] = {}
            end
            if values.empty?
              mappings.delete(item)
            end
          end
        end
      end
      # #binding.pry
      
      return mappings
      
      
    end
    
    def pivot_schema_property_path(items, path_relation)
      mappings = {}
      input_set = @args[:input]
      direction = @args[:direction]

      source_items = items
      limit = @args[:limit]
      limit ||= source_items.size

      if(path_relation.is_a? String)
        path_relation = Relation.new(path_relation);
      end
      
      puts "RELATION: " << path_relation.inspect

      query = input_set.server.begin_nav_query do |q|
        source_items[0..limit].each do |item|
          q.on(item)

        end
        if direction == "backward"
          q.restricted_domain(path_relation)
        else
          q.restricted_image(path_relation)
        end
      end
      
      partial_values_set = Set.new
      
      partial_path_results = query.execute

      if(direction == "backward")

        partial_path_results.each do |item, relations_hash|
          relations_hash.each do |relation, values|
            values.each do |value|
              mappings[value] ||= {}
              mappings[value][item] = {}
            end
          end  
        end

      else
        partial_path_results.each do |item, relations_hash|
          mappings[item] = {}

          relations_hash.each do |key, values|
            values.each do |v|

              mappings[item][v] = {}
            end

            if values.empty?
              mappings.delete(item)
            end
          end
        end
      end
      # #binding.pry
      
      return mappings
    end
    
    def eval
      relations = @args[:relations]
      direction = @args[:direction]
      input_set = @args[:input]
      start_time  = Time.now
      if relations.nil?
        relations = input_set.relations
      end
      mappings = {}
      # mappings = input_set.each_item.map{|i| [i, {}]}.to_h
      local_mappings = mappings
      items = input_set.each_item.to_a
      if !items.empty?
        if(@args[:path])
          
          if schema_relations?(relations)
            partial_mappings = pivot_schema_property_path(items.to_a, relations)
          else
            partial_mappings = pivot_mixed_property_path(items.to_a, relations)
          end
          mappings = partial_mappings
          # #binding.pry
        else
          if(!relations.respond_to?(:each))
            relations = [relations]
          end
          relations.each do |relation|
            if(is_schema?(relation))
              relation_mappings = pivot_schema_property_path(items, [relation])
            else
              relation_mappings = pivot_mixed_property_path(items, [relation])
            end
            
            
            HashHelper.unite(mappings, relation_mappings)
          end
        end
      end
      
    
      # pivot_mappings = build_pivot_result_set(mappings)
      pivot_mappings = mappings
      # puts "RESULTS"
      finish_time = Time.now
      puts "EXECUTED PIVOT FORWARD: " << (finish_time - start_time).to_s
      # HashHelper.print_hash(pivot_mappings)
      return pivot_mappings
    end
    
    def path?(relation)
      relation.respond_to? :each
    end
    
    def build_pivot_result_set(mappings)
      item_relation_index = {}
      self_copy = Xset.new{|s| s.extension = @args[:input].extension_copy}

      pivot_mappings= {}

      mappings.each do |item, relations|
        item_subset = {}
        pivot_mappings[item] = item_subset
        relations.each do |relation, values|

          HashHelper.leaves(values).each do |result_item|
            if(result_item.to_s.include?("Held"))
              # #binding.pry
            end
            item_subset[result_item] = {}
          end
        end
      end
      pivot_mappings
    end  
    
    
    def expression
      relations_exp = ""
      relations = @args[:relations]
      if(!relations.respond_to? :each)
        relations = [relations]
      end
      relations.compact!
      relations.each do |r|
        if r.is_a? Array
          relations_exp << "[" << r.map{|r| r.is_a?(String)? r : r.id}.join(",") << "]"
        elsif r.is_a? Xset
          relations_exp << "Xset.load('#{r.id})'"
        else
          relations_exp << (r.is_a?(String)? r : r.id)
        end

      end
      "pivot_#{@args[:direction]}(#{@args[:input].id}, #{relations_exp})"
    end
  end
  
  def pivot(args = {})
    execute_operation(Pivot, args)
  end
  
  def pivot_forward(args = {})
    args[:direction] = "forward"
    execute_operation(Pivot, args)
  end
  
  def pivot_backward(args = {})
    args[:direction] = "backward"
    execute_operation(Pivot, args)
  end
end