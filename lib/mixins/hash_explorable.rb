module HashExplorable 
  def self.included klass
    klass.class_eval do
      include AuxiliaryOperations
    end
  end
  
  def relations(level=1)
    mappings = {}    
    query = @server.begin_nav_query do |q|
      each_entity(level) do |item|

        q.on(item)      
      end
      q.find_relations
    end
    query.execute.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        mappings[relation] ||= {}        
      end
    end
    
    query = @server.begin_nav_query do |q|
      each_entity(level) do |item|

        q.on(item)      
      end
      q.find_backward_relations
    end
    query.execute.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        r = Relation.new(relation.id)
        r.servers = relation.servers
        r.inverse = true

        mappings[r] ||= {}
        mappings[r]
      end
    end
    mount_result_set("#{self.intention}.relations()", mappings)
  end
  
  def pivot(level=1)
    mappings = {}
    results_hash = {}
    relations = self.relations(level).extension.keys.flatten
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
      relations.each do |relation, values|        
        if level > 1
          pivot_mappings = self_copy.extension if pivot_mappings.empty?
          entities.each do |items_hash|


            if items_hash.has_key? item

              HashHelper.leaves(relations).each do |result_item|
                items_hash.delete(item)
                items_hash[result_item] = {}
              end            
            end
          end


        else
          pivot_mappings[item][relation] = {}
          values.each do |key, values|
            pivot_mappings[item][relation][key] = values
          end
          # relation.set_children(values.keys)
        end        
      end      
    end

    mount_result_set("#{self.intention}.pivot", pivot_mappings)
  end
  
  def pivot_backward(relations, level=1)
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
    pivot_mappings = build_pivot_result_set(mappings, level)

    mount_result_set("pivot_backward", pivot_mappings, {:relations => relations.inspect})
  end  
  
  def pivot_forward(relations, level=1)
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


    pivot_mappings = build_pivot_result_set(mappings, level)    
    mount_result_set("#{self.intention}.pivot_forward(\"#{relations.to_s}\")", pivot_mappings, {:relation => relations.to_s})
  end
  
  def build_pivot_result_set(mappings, level)
    self_copy = Xset.new{|s| s.extension = self.extension_copy}
    entities = self_copy.entities_of_level(level)    
    pivot_mappings= {}
    mappings.each do |item, relations|
      if level > 1
        pivot_mappings = self_copy.extension if pivot_mappings.empty?


        entities.each do |items_hash|


          if items_hash.has_key? item




            HashHelper.leaves(relations).each do |result_item|
              items_hash.delete(item)
              items_hash[result_item] = {}
            end            
          end
        end


      else
        HashHelper.leaves(relations).each do |result_item|
          pivot_mappings[result_item] = {}
        end        
      end
    end
    pivot_mappings    
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
  
  def refine(level=1, &block)
    mappings = {}
    yield(Filtering)
    mappings = Filtering.eval_filters(self)
    mount_result_set("#{self.intention}.refine()", mappings, {:filter => Filtering})
  end

  def group(relation, level=1)
    mappings = {}
    parents_hash = {}
    if level > 1
      self_copy = Xset.new{|s| s.extension = self.extension_copy}
      self_copy.server = self.server
      level_items = self_copy.select_level(level)
      level_items.each do |level_item_hash|        
        subset = Xset.new do |s|
          s.extension = level_item_hash
          s.server = self.server
        end
        partial_result_set = subset.group(relation)
        HashHelper.print_hash(partial_result_set.extension)
        
        level_item_hash.keys.each do |key|
          level_item_hash.delete(key)         
        end
        partial_result_set.extension.each do |result_key, result_values|
          level_item_hash[result_key] = result_values
        end
      
      end
      
      mappings = self_copy.extension
    else
      query = self.server.begin_nav_query do |q|
        each_entity do |item|
          q.on(item)

        end
        q.restricted_image(relation)
      end
    

      mappings = {}
      results_hash = query.execute

      results_hash.each do |subject, relations|
        if !relations.empty?

          group_relation = relations.keys.first 
          inverse_relation = Relation.new(group_relation.id, true);
          objects = results_hash[subject][group_relation]

          objects ||= []
          objects.each do |object|
            if mappings[object].nil?
              mappings[object] ||={}
            end
            mappings[object] ||= {}
            mappings[object][subject] = {}
          end
        end
      end
    end

    mount_result_set("#{self.intention}.group(\"#{relation.to_s}\")", mappings, {:grouping_expression => relation})
  end

  #post condition 1: substitute the images of the original set by the mapped values and preserve the keys
  def map(level=1, &block)
    mappings = {}
    function = yield(MappingFunctions)
    function.origin_set = self
    self_copy = Xset.new{|s| s.extension = self.extension_copy}
    self_copy.server = self.server
    
    self_copy.get_level(level).each do |item_hash|
      if(level > 1)
        intermediary_set = Xset.new{|s| s.extension = item_hash}
        intermediary_set.server = self.server
        intermediary_map_result = intermediary_set.map{function}

        item_hash.keys.each do |key|
          item_hash.delete(key)
        end
        intermediary_map_result.extension.each do |result_key, result_values|
          item_hash[result_key] = result_values
        end
      else
        item_hash.keys.each do |key|
          function.map(key)
        end
      end      
    end
    if level > 1
      mappings = self_copy.extension
    else
      mappings = function.mappings
    end
    mount_result_set("map", mappings, {:mapping_function => function})
  end
  
  def find_path(target_set, level=1)
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
  
  def merge(target_xset)
    self_extension_copy = self.extension
    target_extension_copy = target_xset.extension_copy
    merge_hash(self_extension_copy, target_extension_copy)
    return self
  end

  def intersect(xset, level=1)
    mappings = {}
    copied_extension = self.extension_copy
    intersection_items = self.extension.keys & xset.extension.keys
    intersection_items.each do |item|
      mappings[item] = copied_extension[item]
    end    
    mount_result_set("intersect", mappings, {:xset => xset})
  end
  

  def diff(xset, level=1)
    mappings = {}
    copied_extension = self.extension_copy
    diff_items = copied_extension.keys - xset.extension.keys
    diff_items.each do |item|
      mappings[item] = copied_extension[item]
    end
    mount_result_set("diff", mappings, {:xset => xset})
  end
    
  def union(xset, level=1)
    mappings = {}
    self_copy = self.extension_copy    
    HashHelper.unite(self_copy, xset.extension)
    mount_result_set("union", self_copy, {:xset => xset})
  end
  
  def rank(level=0, &block)
    mappings = {}
    ranking_function = nil
    if(block_given?)
      ranking_function = yield(RankingFunctions)
    end
    
    mappings = self.extension.sort do |item1_hash, item2_hash| 
      (ranking_function.score(self, item1_hash) <=> ranking_function.score(self, item2_hash)) * -1
    end.to_h
    
    mount_result_set("#{self.intention}.rank{|s|s.#{ranking_function.name}}", mappings)
  end

  def mount_result_set(intention, mappings, bindings=nil, level=1)

    result_set = Xset.new do |s|
      s.extension = mappings
      s.resulted_from = self
      s.server = server
      s.intention = intention
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
