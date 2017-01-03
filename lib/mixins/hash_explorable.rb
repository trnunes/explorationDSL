
module HashExplorable 
  
  def relations
    mappings = {}
    query = @server.begin_nav_query do |q|

      if !root?
        items = []
        if empty_image?
          items = domain()
        else
          items = image()          
        end
        items.each do |item|
          q.on(item)
        end
      end
      q.find_relations
    end    
    results_hash = query.execute
    results_hash.each_pair do |key, values|
      relation_ids_for_item = Set.new(values.keys)
      mappings[key] = relation_ids_for_item
    end
    
    mount_result_set("#{self.intention}.relations", mappings)
  end
  
  def root?
    resulted_from.nil? && extension.empty?
  end

  def path?(relation)
    relation.respond_to? :each
  end
  
  def pivot_forward(relations)
    mappings = {}
    results_hash = {}
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end
      if empty_image?
        source_items = domain()
      else
        source_items = image()
      end
      
      relation_mappings = {}
      relation.each do |path_relation|        
        query = @server.begin_nav_query do |q|
          if !root?
            source_items.each do |item|
              q.on(item)
            end
          end
          q.restricted_image(path_relation)
        end
        partial_values_set = Set.new
        
        partial_path_results = query.execute
        
        partial_path_results.each do |item, relations_hash|
          relations_hash.each do |key, values|
            relations_hash[key] = Set.new(values)
            if values.empty?
              partial_path_results.delete(item)
            end
            partial_values_set += values
          end  
        end
        relation_mappings = join(relation_mappings, partial_path_results)        
        source_items = partial_values_set
      end
      add_hash(mappings, relation_mappings)
    end

    mount_result_set("#{self.intention}.pivot_forward(\"#{relations.to_s}\")", mappings, {:relation => relations.to_s})
  end
  
  def add_hash(hash1, hash2)
    added_hash = {}
    hash2.each do |key, values|
      if values.is_a? Hash
        values.each do |relation_key, relation_values|
          hash1[key] ||= {}
          hash1[key][relation_key] = relation_values
        end        
      else
        hash1[key] ||= Set.new
        hash1[key] = values
      end      
    end    
  end
  
  def join(source_hash, target_hash)    
    merged_hash = {}
    if source_hash.empty?
      return target_hash
    end
    if target_hash.empty?
      return source_hash
    end
    source_hash.each do |key, values|
      source_hash.delete(key) if values.empty?
    end

    target_hash.each do |key, values|
      target_hash.delete(key) if values.empty?
    end    
    source_hash.each do |key, values|
      merged_hash[key] ||= {}
      if values.is_a? Hash
        merged_values = join(values, target_hash)
        merged_hash[key] = merged_values   
      else
        values.each do |value|        
          if target_hash.has_key? value
            merged_hash[key][value] = target_hash[value]
          end
        end
      end
    end
    merged_hash
  end
  
  def pivot_backward(relations)
    mappings = {}
    results_hash = {}
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end
      if empty_image?
        source_items = domain()
      else
        source_items = image()
      end
      
      relation_mappings = {}
      local_inverted_mappings = {}
      relation.each do |path_relation|        
        query = @server.begin_nav_query do |q|
          if !root?
            source_items.each do |item|
              q.on(item)
            end
          end
          q.restricted_domain(path_relation)
        end
        partial_values_set = Set.new
        
        partial_path_results = query.execute
        
        partial_path_results.each do |item, relations_hash|
          relations_hash.each do |relation, values|
            values.each do |value|
              if local_inverted_mappings[value].nil?
                local_inverted_mappings[value] = {relation => Set.new()}
              end
              local_inverted_mappings[value][relation] << item              
            end
            partial_values_set << item
          end  
        end
        relation_mappings = join(relation_mappings, local_inverted_mappings)        
        source_items = partial_values_set
      end
      add_hash(mappings, relation_mappings)
    end
    mount_result_set("pivot_backward", mappings, {:relations => relations.inspect})
  end

  def invert_hash(hash)
    mappings = {}
    hash.each do |item, relation_hash|
      relation_hash.each do |relation_id, values|        
        values.each do |value|
          if mappings[value].nil?
            mappings[value] = {relation_id => Set.new()}
          end
          mappings[value][relation_id] << item
        end
      end
    end
    mappings    
  end
  
  def pivot
    mappings = {}
    extension.each_key do |key|
      extension[key].each do |value|
        mappings[value] ||= Set.new
        mappings[value] << key
      end
    end
    mount_result_set("pivot", mappings)
  end

  def refine(&block)



    yield(Filtering)

    mappings = Filtering.eval_filters(self)
    mount_result_set("#{self.intention}.refine()", mappings, {:filter => Filtering})
  end

  def group(relation)
    mappings = {}

    query = @server.begin_nav_query do |q|
      if !root?
        all_items do |item|
          q.on(item)
        end
      end
      q.restricted_image(relation)
    end

    mappings = {}
    results_hash = query.execute
    results_hash.each_key do |subject|
      objects = results_hash[subject][Entity.new(relation.to_s)]

      objects ||= []
      objects.each do |object|
        if mappings[object].nil?
          mappings[object] = {Entity.new("group") => Set.new()}
        end
        mappings[object][Entity.new("group")] << subject
      end
    end
    mount_result_set("#{self.intention}.group_by(\"#{relation.to_s}\")", mappings, {:grouping_expression => relation})
  end

  #post condition 1: substitute the images of the original set by the mapped values and preserve the keys
  def map(&block)
    mappings = {}
    function = yield(MappingFunctions)
    function.origin_set = self
    all_items do |item|
      function.map(item)
    end
    mount_result_set("map", function.mappings, {:mapping_function => function})
  end
  
  def find_path(target_set)
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

  def merge_extension(extension)
    cloned_extension = self.extension
    merged_extension = {}
    
    if extension == cloned_extension
      return cloned_extension
    end
    
    
    self.generates.each do |generated_set|

      merged_extension_generated_sets = generated_set.merge_extension(extension)
      
      

      merged_extension_generated_sets.each_key do |key|
        domains = self.each_domain([key])
        
        
        if(!domains.nil?)

          domains.each do |domain|
            merged_extension[domain] ||= {}
            merged_extension[domain][key] = merged_extension_generated_sets[key]
          end

        end
      end
    end
    return merged_extension
  end

  def merge(xset)
    if(self.root?)
      return xset
    end
    if self.empty_image?
      merged_extension = merge_ext_on_domain(self.extension_copy, xset.extension_copy)
    else
      merged_extension = merge_ext_on_image2(self.extension_copy, xset.extension_copy)
    end
    mount_result_set("merge", merged_extension, {:xset => xset})
  end

  def recursive_merge(xset)
    merged_extension = merge_ext(self.extension, xset.extension)
    
    self.generates.each do |generated_set|
    end
    mount_result_set("merge", merged_extension, {:xset => xset})
  end

  def merge_ext_on_domain(origin_extension, target_extension)
    merged_extension = {}
    origin_extension.keys.each do |domain_item|
      if target_extension.has_key?(domain_item)
        merged_extension[domain_item] = target_extension[domain_item]        
      end      
    end
    merged_extension    
  end
  
  def merge_ext_on_image(origin_extension, target_extension)
    merged_extension = {}
    origin_extension.each_pair do |key, values|
      if(values.is_a? Hash)
        image_merged_extension = merge_ext_on_image(values, target_extension)
        merged_extension.merge!(image_merged_extension)
      else
        if !values.respond_to? :each
          values = [values]
        end
        values.each do |value|
          target_image = target_extension[value]
          if !target_image.nil?
            merged_extension[key] ||={}
            merged_extension[key][value] = target_image
          end
        end
      end
    end
    
    return merged_extension
  end
  
  def merge_ext_on_image2(origin_extension, target_extension)
    merged_extension = origin_extension
    merged_extension.each do |item, relations|
      relations.each do |relation, image|
        merged_extension[item][relation] = {}
        if image.is_a? Hash
          merged_value_hash = merge_ext_on_image2(value, target_extension)
          value_key = value.keys.first
          merged_value_hash.each do |value, value_relations|
            merged_extension[item][relation][value] =value_relations
          end
        else
          image.each do |value|
            merged_extension[item][relation][value] = target_extension[value] if target_extension.has_key?(value)
          end
        end
      end
    end
    merged_extension
  end

  def intersect(xset)
    mappings = {}
    if xset.empty_image?
      mappings = intersect_on_domain(xset)
    else
      mappings = intersect_on_image(xset)
    end
    
    mount_result_set("intersect", mappings, {:xset => xset})
  end
  
  def intersect_on_domain(xset)
    extension_copy = self.extension_copy
    target_extension = xset.extension
    intersection = {}
    intersection_items = extension_copy.keys & target_extension.keys
    intersection_items.each do |item|
      intersection[item] = extension_copy[item]
    end    
    intersection
  end
  
  def intersect_on_image(xset)
    intersection = {}
    target_set_image = xset.image()
    self.extension.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        intersection_on_key = self.extension[item][relation] & target_set_image
        if !intersection_on_key.empty?
          intersection[item] ||= {}
          intersection[item][relation] = intersection_on_key 
        end
      end
    end
    intersection
  end

  def diff(xset)
    mappings = {}
    if xset.empty_image?
      mappings = diff_on_domain(xset)
    else
      mappings = diff_on_image(xset)
    end
    mount_result_set("diff", mappings, {:xset => xset})
  end
  
  def diff_on_domain(xset)
    diff_map = {}
    diff_items = self.extension.keys - xset.extension.keys
    diff_items.each do |item|
      diff_map[item] = self.extension[item]
    end
    diff_map
  end
  
  def diff_on_image(xset)
    diff_map = {}
    target_set_image = xset.image()
    self.extension_copy.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        target_set_image.each do |item_to_diff|
          values.delete(item_to_diff)
        end
        if !values.empty?
          diff_map[item] ||={}
          diff_map[item][relation] = values
        end
      end
    end
    diff_map
  end


  def rank(&block)
    ranking_function = nil
    if(block_given?)
      ranking_function = yield(RankingFunctions)
    end    
    result_set = RankedSet.new(self, ranking_function)
    return result_set
  end

  def mount_result_set(intention, mappings, bindings=nil)

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
    return result_set
  end
  
  def save
    
  end
end
