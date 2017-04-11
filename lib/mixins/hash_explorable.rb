module HashExplorable 
  def self.included klass
    klass.class_eval do
      include AuxiliaryOperations
    end
  end
  
  def relations(args={})
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    
    mappings = {}
    result_relation_index = {}
    query = @server.begin_nav_query do |q|
      each_entity do |item|
        q.on(item)      
      end
      q.find_relations
    end
    query.execute.each do |item, relations_hash|
      result_relation_index[item] = {}
      mappings[item] = Xsubset.new(item){|s| s.server = self.server}
      relations_hash.each do |relation, values|
        mappings[item] << relation
        item.add_child(relation)
      end
    end
    
    query = @server.begin_nav_query do |q|
      each_entity do |item|
        q.on(item)      
      end
      q.find_backward_relations
    end
    query.execute.each do |item, relations_hash|
      mappings[item] ||= Xsubset.new(item){|s| s.server = self.server}
      relations_hash.each do |relation, values|
        r = Relation.new(relation.id)
        r.servers = relation.servers
        r.inverse = true
        r.text += " of"

        mappings[item] << r
      end
    end
    finish_time = Time.now


    mount_result_set("#{self.intention}.relations()", mappings, result_relation_index)
  end
  

  def pivot(args={})
    start_time = Time.now
    
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    backward_relations = []
    forward_relations = []
    mappings = {}
    self.relations.each do |relation|
      if relation.inverse
        backward_relations << relation 
      else
        forward_relations << relation
      end
    end
    forward_pivot = pivot_forward(forward_relations, args)
    backward_pivot = pivot_backward(backward_relations, args)
    if !forward_pivot.nil? && !forward_pivot.empty?
      mappings.merge!(forward_pivot.extension)
    end
    if !backward_pivot.nil? && !backward_pivot.empty?
      mappings.merge!(backward_pivot.extension){|item, subset1, subset2| subset1.extension.merge!(subset2.extension); subset1 }
    end
    finish_time = Time.now



    mount_result_set("#{self.intention}.pivot", mappings)
  end
  
  def pivot_backward(relations, args={})
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    results_hash = {}
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end

      source_items = each_item
      
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
            inverse_relation.text = relation.text + " of"
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
    
    finish_time = Time.now
    puts "EXECUTED PIVOT BACKWARD: " << (finish_time - start_time).to_s

    mount_result_set("pivot_backward", pivot_mappings, result_relation_index, {:relations => relations.inspect})
  end  
    
  def pivot_forward(relations, args={})
    start_time  = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    results_hash = {}
    partial_values_set = Set.new


    
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end

      source_items = each_item
      




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

        relation_mappings = partial_path_results
        source_items = partial_values_set
      end
      mappings.merge!(relation_mappings){|item, relation1, relation2| relation1.merge(relation2)}
    end
    pivot_mappings, result_relation_index = build_pivot_result_set(mappings, level, relations.size > 1, keep_structure)   

    finish_time = Time.now
    puts "EXECUTED PIVOT FORWARD: " << (finish_time - start_time).to_s


    mount_result_set("#{self.intention}.pivot_forward(\"#{relations.to_s}\")", pivot_mappings, result_relation_index, {:relation => relations.to_s})
  end
  
  def build_pivot_result_set(mappings, level, is_multiple, keep_structure)
    item_relation_index = {}
    self_copy = Xset.new{|s| s.extension = self.extension_copy}

    pivot_mappings= {}

    # HashHelper.print_hash(mappings)
    mappings.each do |item, relations|
      item_subset = Xsubset.new(item){|s| s.server = self.server}
      pivot_mappings[item] = item_subset
      relations.each do |relation, values|
        # item.add_child(relation)
        item_subset[relation] = Xsubset.new(relation){|s| s.server = self.server}
        # HashHelper.leaves(values).each do |result_item|
        #   item_subset[relation][result_item] = {}
        #   # relation.add_child(result_item);
        # end
        values.keys.each do |result_item|
          item_subset[relation][result_item] = {}
          # relation.add_child(result_item);
        end
        
      end
    end
    [pivot_mappings, item_relation_index]
      
  end
  
    
  def select_items(items)
    start_time = Time.now
    self.save
    result_items = Set.new
    search_items(items, result_items)
    finish_time = Time.now

    
    mount_result_set("#{self.intention}.select_items(\"#{items.to_s}\")", result_items.map{|i| [i, {}]}.to_h, {:items => items.to_s})
  end
  
  def select_subsets(subsets)
    self.save
    result_items = Set.new
    search_subsets(items, result_items)
    mount_result_set("#{self.intention}.select_subsets(\"#{items.to_s}\")", result_items.map{|i| [i, {}]}.to_h, {:items => items.to_s})
  end
  
  def refine(args={}, &block)
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    yield(Filtering)
    if(has_subsets? && args[:apply_to_subsets])
      each_image do |subset|
        subset_mappings = Filtering.eval_filters(subset)
        mappings[subset] = Xsubset.new(subset.key){|s| s.server = self.server; s.extension = subset_mappings}
      end
    else
      mappings = Filtering.eval_filters(self)
    end
    Filtering.clear
    finish_time = Time.now
    puts "EXECUTED REFINE: " << (finish_time - start_time).to_s
    mount_result_set("#{self.intention}.refine()", mappings, {:filter => Filtering})
  end

  def group(args={}, &block)
    start_time = Time.now
    self.save
    
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    grouping_function = yield(Grouping)
    mappings = {}
    result_relation_index = {}
    parents_hash = {}
    if has_subsets?
      self.each_image do |subset|
        
        grouped_subset = subset.group{grouping_function}
        
        mappings[subset] = Xsubset.new(subset.key){|s|s.server = self.server; s.extension = grouped_subset.extension}
      end
    else
      groups = grouping_function.group(self)
      mappings = {}
      groups.each do |group_key, group_values|
        subset = Xsubset.new(group_key){|s| s.server = self.server; s.extension = group_values}
        subset.server = self.server
        mappings[group_key] = subset
      end    
    end
    finish_time = Time.now
    puts "EXECUTED GROUP: " << (finish_time - start_time).to_s
    mount_result_set("#{self.intention}.group", mappings, {})
  end

  #post condition 1: substitute the images of the original set by the mapped values and preserve the keys
  def map(args={}, &block)
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    function = yield(Mapping)
    result_relation_index = {}
    function.origin_set = self

    if(has_subsets?)
      
      self.each_image do |subset|
        grouped_subset = subset.map{function}
        mappings.merge! grouped_subset.extension
      end
    else
      mappings = function.map(self)
    end
    finish_time = Time.now
    puts "EXECUTED MAP: " << (finish_time - start_time).to_s
    mount_result_set("map", mappings, result_relation_index, {:mapping_function => function})
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
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}

    intersection_items = self.each_item & xset.each_item
    mappings = intersection_items.map{|item| [item, {}]}.to_h
    finish_time = Time.now
    puts "EXECUTED INTERSECT: " << (finish_time - start_time).to_s
    mount_result_set("intersect", mappings, {:xset => xset})
  end  

  def diff(xset, args={})
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    source_items = self.each_item
    target_items = xset.each_item
    diff_items = source_items - target_items
    mappings = diff_items.map{|item| [item,{}]}.to_h

    finish_time = Time.now
    puts "EXECUTED DIFF: " << (finish_time - start_time).to_s
    mount_result_set("diff", mappings, {:xset => xset})
  end
    
  def union(xset, args={})
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    
    mappings = self.extension_copy
    self_images = self.each_image
    target_images = xset.each_image
    mappings = (self_images + target_images).map do |image| 
      if image.is_a? Xsubset
        [image, image]
      else
        [image, {}]
      end
    end.to_h
    finish_time = Time.now
    puts "EXECUTED UNION: " << (finish_time - start_time).to_s
    # HashHelper.unite(self_copy, xset.extension)
    if args[:inplace]
      self.extension = mappings
      self
    else      
      mount_result_set("union", mappings, {:xset => xset})
    end
    
  end
  
  def rank(args={}, &block)
    start_time = Time.now
    self.save
    level = args[:level].nil? ? 1 : args[:level]
    
    multiplier = -1

    if(args[:order] == "ASC")
      multiplier = 1
    end
    keep_structure = args[:keep_structure].nil? ? false : args[:keep_structure]
    mappings = {}
    ranking_function = nil
    if(block_given?)
      ranking_function = yield(Ranking)
    end
    ranking_function.source_set = self
    
    mappings = self.extension.sort do |item1_array, item2_array|
      comparable1 = (item1_array[1].nil? || item1_array[1].empty?) ? item1_array[0] : item1_array[1]
      comparable2 = (item2_array[1].nil? || item2_array[1].empty?) ? item2_array[0] : item2_array[1]

      score_1 = ranking_function.score(comparable1)
      score_2 = ranking_function.score(comparable2)
      # binding.pry
      comparison = (score_1 <=> score_2 )
      if comparison.nil?
        if score_1 == -Float::INFINITY
          1
        elsif score_2 == -Float::INFINITY
          -1
        else
          (score_1.to_s <=> score_2.to_s) * multiplier
        end
                  
      else
        (score_1 <=> score_2 ) * multiplier
      end      
    end.to_h
    finish_time = Time.now
    puts "EXECUTED RANK: " << (finish_time - start_time).to_s
    mount_result_set("#{self.intention}.rank{|s|s.#{ranking_function.name}}", mappings)
  end

  def flatten()
    start_time = Time.now
    self.save
    mappings = {}
    
    self.each_item do |item|
      mappings[item] = item
    end
    finish_time = Time.now
    puts "EXECUTED FLATTEN: " << (finish_time - start_time).to_s
    mount_result_set("#{self.intention}.flatten()", mappings)
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
