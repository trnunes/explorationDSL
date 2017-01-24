
module HashExplorable 
  def self.included klass
    klass.class_eval do
      include AuxiliaryOperations
    end
  end
  
  def relations
    mappings = {}    
    query = @server.begin_nav_query do |q|
      each do |item|
        q.on(item)      
      end
      q.find_relations
    end
    query.execute.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        mappings[relation] ||= {}
        mappings[relation][item] = Relation.new("http://www.tecweb.inf.puc-rio.br/xpair/has_relation")
      end
    end
    mount_result_set("#{self.intention}.relations()", mappings)
  end
  
  def pivot_forward(relations)
    mappings = {}
    results_hash = {}
    relations.each do |relation|
      if !path?(relation)
        relation = [relation]
      end

      source_items = domain(false)
      
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
    
    pivoted_mappings = pivot_hash(mappings)    


    mount_result_set("#{self.intention}.pivot_forward(\"#{relations.to_s}\")", pivoted_mappings, {:relation => relations.to_s})
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
  
  def image_merge(target_set)
  end
  
  def domain_merge(target_set)
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

      source_items = domain(false)
      
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
    pivoted_mappings = pivot_hash(mappings)
    mount_result_set("pivot_backward", pivoted_mappings, {:relations => relations.inspect})
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
        each do |item|
          q.on(item)
        end
      end
      q.restricted_image(relation)
    end
    

    mappings = {}
    results_hash = query.execute
    puts "GROUP RESULTS: #{results_hash.inspect}"
    results_hash.each do |subject, relations|
      group_relation = relations.keys.first
      group_relation.inverse = true if !group_relation.nil?
      objects = results_hash[subject][group_relation]

      objects ||= []
      objects.each do |object|
        if mappings[object].nil?
          mappings[object] ||={}
        end
        mappings[object][subject] = group_relation
      end
    end
    mount_result_set("#{self.intention}.group(\"#{relation.to_s}\")", mappings, {:grouping_expression => relation})
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
    copied_extension = self.extension_copy
    intersection_items = self.extension.keys & xset.extension.keys
    intersection_items.each do |item|
      mappings[item] = copied_extension[item]
    end    
    mount_result_set("intersect", mappings, {:xset => xset})
  end
  

  def diff(xset)
    mappings = {}
    copied_extension = self.extension_copy
    diff_items = copied_extension.keys - xset.extension.keys
    diff_items.each do |item|
      mappings[item] = copied_extension[item]
    end
    mount_result_set("diff", mappings, {:xset => xset})
  end
  
  def rank(&block)
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
