module HashExplorable 
  def self.included klass
    klass.class_eval do
      include AuxiliaryOperations
    end
  end
  
  def relations(args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    
    mappings = {}
    result_relation_index = {}
    query = @server.begin_nav_query do |q|
      each_entity(level) do |item|

        q.on(item)      
      end
      q.find_relations
    end
    query.execute.each do |item, relations_hash|
      result_relation_index[item] = {}
      relations_hash.each do |relation, values|
        mappings[relation] ||= {}
        result_relation_index[item][relation] = {}
        item.add_child(relation)
      end
    end
    
    query = @server.begin_nav_query do |q|
      each_entity(level) do |item|
        q.on(item)      
      end
      q.find_backward_relations
    end
    query.execute.each do |item, relations_hash|
      result_relation_index[item] ||= {}
      relations_hash.each do |relation, values|
        r = Relation.new(relation.id)
        r.servers = relation.servers
        r.inverse = true

        mappings[r] ||= {}
        result_relation_index[item][r] = {}
      end
    end
    mappings = result_relation_index if keep_structure
    mount_result_set("#{self.intention}.relations()", mappings, result_relation_index)
  end
  
  def pivot(args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    results_hash = {}
    result_relation_index = {}
    relations = self.relations(level: level).extension.keys.flatten
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end

      source_items = entities_of_level(level)
      parents_map = {}
      relation_mappings = {}
      relation.each do |path_relation|        

        query = @server.begin_nav_query do |q|

          source_items.each do |item_hash|
            item_hash.keys.each do |key|
              q.on(key)
            end
          end

          if path_relation.inverse
            q.restricted_domain(path_relation)
          else
            q.restricted_image(path_relation)
          end
          
        end
        partial_values_set = Set.new
        
        partial_path_results = {}
        if path_relation.inverse

          query.execute.each do |item, relations_hash|

            relations_hash.each do |relation, values|
              values.each do |value|
                inverse_relation = Relation.new(relation.id);
                inverse_relation.inverse = true;
                partial_path_results[value] ||= {}
                partial_path_results[value][inverse_relation] ||= {}
                partial_path_results[value][inverse_relation][item] = {};
              end
            end
          end
                  
        else
           query.execute.each do |item, relations|
             partial_path_results[item] = {}
             relations.each do |relation, values|
               values.each do |v| 
                 partial_path_results[item][relation] ||= {}
                 partial_path_results[item][relation][v] = {}
               end
             end
           end
        end
        relation_mappings = HashHelper.join(relation_mappings, partial_path_results)        
        source_items = partial_values_set
      end
      HashHelper.unite(mappings, relation_mappings)
    end
    pivot_mappings= {}


    mappings.each do |item, relations|

      pivot_mappings[item] = {}    
      result_relation_index[item] = {}
      relations.each do |relation, values|        
        item.add_child(relation)
        
        if level > 1
          pivot_mappings = self_copy.extension if pivot_mappings.empty?
          entities.each do |items_hash|


            if items_hash.has_key? item

              HashHelper.leaves(relations).each do |result_item|
                items_hash.delete(item)
                items_hash[result_item] = {}
                result_relation_index[item][result_item] = {}
                
              end            
            end
          end


        else
          pivot_mappings[item][relation] = {}
          
          values.each do |key, values|
            pivot_mappings[item][relation][key] = values
            relation.add_child(key)
          end
          result_relation_index[item] = pivot_mappings[item]
          # relation.set_children(values.keys)
        end        
      end      
    end

    mount_result_set("#{self.intention}.pivot", pivot_mappings, result_relation_index)
  end
  
  def pivot_backward(relations, args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    results_hash = {}
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end

      source_items = entities(level)
      
      relation_mappings = {}
      local_inverted_mappings = {}
      relation.each do |path_relation|        
        query = @server.begin_nav_query do |q|
          source_items.each do |item|
            q.on(item)
          end
          q.restricted_domain(path_relation)
        end
        partial_values_set = Set.new
        
        partial_path_results = query.execute
        
        partial_path_results.each do |item, relations_hash|
          relations_hash.each do |relation, values|
            inverse_relation = Relation.new(relation.id, true);
            values.each do |value|
              if local_inverted_mappings[value].nil?
                local_inverted_mappings[value] = {inverse_relation => {}}
              end
              local_inverted_mappings[value][inverse_relation][item] = {}
            end
            partial_values_set << item
          end  
        end
        relation_mappings = HashHelper.join(relation_mappings, local_inverted_mappings)        
        source_items = partial_values_set
      end
      HashHelper.unite(mappings, relation_mappings)
    end
    pivot_mappings, result_relation_index = build_pivot_result_set(mappings, level, relations.size > 1, keep_structure)

    mount_result_set("pivot_backward", pivot_mappings, result_relation_index, {:relations => relations.inspect})
  end  
  
  def pivot_forward(relations, args={})
    level = args[:level].nil? ? 1 : args[:level]
    
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    results_hash = {}
    partial_values_set = Set.new
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end

      source_items = entities(level)


      relation_mappings = {}

      relation.each do |path_relation|        

        query = @server.begin_nav_query do |q|
          source_items.each do |item|
            q.on(item)
          end
          q.restricted_image(path_relation)
        end
        partial_values_set = Set.new
        
        partial_path_results = query.execute
        
        partial_path_results.each do |item, relations_hash|
          relations_hash.each do |key, values|
            relations_hash[key] = {}
            values.each do |v|
              relations_hash[key][v] = {}
            end
            if values.empty?
              partial_path_results.delete(item)
            end
            partial_values_set += values
          end
        end

        relation_mappings = HashHelper.join(relation_mappings, partial_path_results)
        source_items = partial_values_set
      end
      HashHelper.unite(mappings, relation_mappings)
    end
    pivot_mappings, result_relation_index = build_pivot_result_set(mappings, level, relations.size > 1, keep_structure)   
    puts "RESULTS"
    HashHelper.print_hash(pivot_mappings) 
    mount_result_set("#{self.intention}.pivot_forward(\"#{relations.to_s}\")", pivot_mappings, result_relation_index, {:relation => relations.to_s})
  end
  
  def build_pivot_result_set(mappings, level, is_multiple, keep_structure)
    item_relation_index = {}
    self_copy = Xset.new{|s| s.extension = self.extension_copy}
    entities = self_copy.entities_of_level(level)
    pivot_mappings= {}
    mappings.each do |item, relations|
      item_subset = {}
      item_relation_index[item] = item_subset
      
      if level > 1

        pivot_mappings = self_copy.extension if pivot_mappings.empty?
        entities.each do |items_hash|
          
          if items_hash.has_key? item
            if is_multiple
              relations.each do |relation, values|
                item_subset[relation] = {}

                HashHelper.leaves(values).each do |result_item|
                  items_hash.delete(item)
                  items_hash[result_item] = {}              
                  item_subset[relation][result_item] = {}
                end
              end
            else
              HashHelper.leaves(relations).each do |result_item|
                items_hash.delete(item)
                items_hash[result_item] = {}
                item_subset[result_item] = {}
              end              
            end
          end
        end
      else
        if is_multiple
          relations.each do |relation, values|
            item.add_child(relation)
            
            item_subset[relation] = {}

            HashHelper.leaves(values).each do |result_item|
              pivot_mappings[result_item] = {}
              item_subset[relation][result_item] = {}
              relation.add_child(result_item);
            end
          end
        else
          HashHelper.leaves(relations).each do |result_item|
            pivot_mappings[result_item] = {}
            item_subset[result_item] = {}
            item.add_child(result_item)
          end
        end
      end
    end
    pivot_mappings = item_relation_index if keep_structure
    [pivot_mappings, item_relation_index]
  end
  
    
  def select(items)
    mappings = {}
    items.each do |item|

      if contains_item?(self.extension, item)

        mappings[item] = {}
      end
    end

    mount_result_set("#{self.intention}.select(\"#{items.to_s}\")", mappings, {:items => items.to_s})
  end
  
  def refine(args={}, &block)
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    yield(Filtering)
    mappings = Filtering.eval_filters(self)
    mount_result_set("#{self.intention}.refine()", mappings, {:filter => Filtering})
  end

  def group(args={}, &block)
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    grouping_function = yield(Grouping)
    mappings = {}
    result_relation_index = {}
    parents_hash = {}
    if level > 1
      self_copy = Xset.new{|s| s.extension = self.extension_copy}
      self_copy.server = self.server
      level_items = self_copy.select_level(level - 1)
      level_items.each do |previous_level_item_hash|
        previous_level_item_hash.each do |key_item, level_item_hash|
          subset = Xsubset.new(self, level) do |s|
            s.extension = HashHelper.copy(level_item_hash)
            s.server = self.server
          end
          partial_result_set = subset.group{grouping_function}

          result_relation_index[subset] = Xsubset.new(self, level){|s| s.extension = partial_result_set.extension}

          level_item_hash.keys.each do |key|
            level_item_hash.delete(key)
          end
          partial_result_set.extension.each do |result_key, result_values|
            level_item_hash[result_key] = result_values
          end
        end  
      end
      
      mappings = self_copy.extension
    else
      mappings = grouping_function.group(self)
      mappings.each do |group_key, group_values|
        group_values.keys.each do |value|
          result_relation_index[value] ||= {}
          result_relation_index[value][group_key] = {}
          value.add_child(group_key)
        end
      end
    end

    group_result_set = mount_result_set("#{self.intention}.group", mappings, {})
    group_result_set.relation_index = result_relation_index
    group_result_set
  end

  #post condition 1: substitute the images of the original set by the mapped values and preserve the keys
  def map(args={}, &block)
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    function = yield(Mapping)
    result_relation_index = {}
    function.origin_set = self
    self_copy = Xset.new{|s| s.extension = self.extension_copy}
    self_copy.server = self.server
    

    if(level > 1)
      self_copy.get_level(level).each do |item_hash|
        intermediary_set = Xsubset.new(self, level){|s| s.extension = item_hash}
        intermediary_set.subset_of = self
        intermediary_set.server = self.server
        intermediary_map_result = intermediary_set.map{function}
        result_relation_index[intermediary_set] = intermediary_map_result

        item_hash.keys.each do |key|
          item_hash.delete(key)
        end
        intermediary_map_result.extension.each do |result_key, result_values|
          item_hash[result_key] = result_values
        end
      end
    else
      mappings, result_relation_index = function.map(self)

    end      
    
    if level > 1
      mappings = self_copy.extension
    end
    map_results = mount_result_set("map", mappings, result_relation_index, {:mapping_function => function})
    
  end
  
  def find_path(target_set, args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    ###
    #TODO Compute mappings
    ###
    result_set = Xset.new do |s|
      s.extension = mappings
      s.resulted_from = self
      s.intention = "find_path"
      s.bindings do |b|
        b[:target_set] = target_set
      end
    end
    return result_set

  end
    
  def local_path(xset)
    
    xset.resulted_from


    path_to_target_hash = merge_extension(xset.extension_copy)
    path_to_target_hash_without_origin_set_domain = {}

    path_to_target_hash.each_key do |key|
      value = path_to_target_hash[key]
      value.each_key do |key|
        path_to_target_hash_without_origin_set_domain[key] = value[key]
      end
    end
    return mount_result_set("local_path", path_to_target_hash_without_origin_set_domain, {:xset => xset})
  end

  
  def merge_hash(merged_hash, hash2)
    hash2.each do |key, values|
      if merged_hash.has_key? key #hashes match on key
        if values.is_a? Hash
          if !merged_hash[key].is_a? Hash
            merged_values = merged_hash[key]
            merged_values.each do |merged_value|
              merged_hash[key][merged_value] ||= {}
            end
          end
          values.each do |value_key, value_values|
            merged_hash[key][value_key] = value_values
          end
        else #if values is a set
          if merged_hash[key].is_a? Hash
            values.each do |value|
              merged_hash[key][value] = {}
            end
          else
            merged_hash[key] += values
          end
        end
      end
    end
    local_merged_hash = {}    
    merged_hash.each do |key, values|
      if values.is_a? Hash
        merge_hash(values, hash2)
      else
        values.each do |value|
          if hash2.has_key? value
            local_merged_hash[key]||= {}
            local_merged_hash[key][value] ||= {}
            local_merged_hash[key][value] = hash2[value]
          end
        end
      end
    end
    if !local_merged_hash.empty?
      local_merged_hash.each do |key, values|
        merged_hash[key] = values
      end
    end
  end
  
  def merge!(target_xsets)
    self_extension_copy = self.extension
    target_xsets.each do |target_xset|
      target_extension_copy = target_xset.extension_copy 
      merge_hash(self_extension_copy, target_extension_copy)
    end
    return self
  end
  
  def merge(target_xsets, args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    self_extension_copy = self.extension_copy
    target_xsets.each do |target_xset|
      target_extension_copy = target_xset.extension_copy 
      merge_hash(self_extension_copy, target_extension_copy)
    end

    mount_result_set("merge", self_extension_copy, {}, {:target_xsets => target_xsets})
  end

  def intersect(xset, args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    copied_extension = self.extension_copy
    intersection_items = self.extension.keys & xset.extension.keys
    intersection_items.each do |item|
      mappings[item] = copied_extension[item]
    end    
    mount_result_set("intersect", mappings, {:xset => xset})
  end  

  def diff(xset, args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    copied_extension = self.extension_copy
    diff_items = copied_extension.keys - xset.extension.keys
    diff_items.each do |item|
      mappings[item] = copied_extension[item]
    end
    mount_result_set("diff", mappings, {:xset => xset})
  end
    
  def union(xset, args={})
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    self_copy = self.extension_copy    
    HashHelper.unite(self_copy, xset.extension)
    mount_result_set("union", self_copy, {:xset => xset})
  end
  
  def rank(args={}, &block)
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    ranking_function = nil
    if(block_given?)
      ranking_function = yield(Ranking)
    end
    ranking_function.source_set = self
    
    mappings = self.extension.sort do |item1_array, item2_array| 
      (ranking_function.score(item1_array[0]) <=> ranking_function.score(item2_array[0])) * -1
    end.to_h
    
    mount_result_set("#{self.intention}.rank{|s|s.#{ranking_function.name}}", mappings)
  end

  def flatten(level)
    mappings = {}
    result_relation_index = {}
    copy_set = Xset.new{|s| s.extension = self.extension_copy}
    copy_set.select_level(level).each do |level_items|
      level_items.keys.each do |key|
        mappings[key] = {}
        result_relation_index[key] = {key=>{}}
      end
    end
    mount_result_set("#{self.intention}.flatten(#{level})", mappings, result_relation_index)
  end
  
  def mount_result_set(intention, mappings, result_relation_index = {}, bindings=nil, level=1)

    result_set = Xset.new do |s|
      s.extension = mappings
      s.resulted_from = self
      s.server = server
      s.intention = intention
      s.relation_index = result_relation_index
      if !bindings.nil?
        s.bindings do |b|
          b = bindings
        end
      end
    end    
    self.generates << result_set
    result_set.save      
    return result_set
  end
  
  def save
    
  end
end
