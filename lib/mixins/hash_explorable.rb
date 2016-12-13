
module HashExplorable 
  
  def relations
    mappings = {}
    query = @server.begin_nav_query do |q|
      if !root?
        all_items do |item|
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
    resulted_from.nil?
  end

  def pivot_forward(relation)
    mappings = {}

    query = @server.begin_nav_query do |q|
      if !root?
        all_items do |item|
          q.on(item)
        end
     end
      q.restricted_image(relation)
    end

    results_hash = query.execute

    results_hash.each_key do |subject|
      results_hash[subject].each_key do |relation|
        mappings[subject] ||= Set.new
        mappings[subject] += results_hash[subject][relation]
      end
    end

    mount_result_set("#{self.intention}.pivot_forward(\"#{relation.to_s}\")", mappings, {:relation => relation.to_s})
  end

  def pivot_backward(relation)
    mappings = {}

    query = @server.begin_nav_query do |q|
      if !root?
        all_items do |item|
          q.on(item)
        end
      end
      q.restricted_domain(relation)
    end

    results_hash = query.execute

    results_hash.each_key do |subject|
      results_hash[subject].each_key do |relation|
        results_hash[subject][relation].each do |value|
          mappings[value] ||= Set.new
          mappings[value] << subject
        end
      end
    end
    mount_result_set("pivot_backward", mappings, {:relation => relation.to_s})
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
          mappings[object] = Set.new
        end
        mappings[object] << subject
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
    merged_extension = merge_ext(self.extension_copy, xset.extension_copy)
    mount_result_set("merge", merged_extension, {:xset => xset})
  end

  def recursive_merge(xset)
    merged_extension = merge_ext(self.extension, xset.extension)
    self.generates.each do |generated_set|
    end
    mount_result_set("merge", merged_extension, {:xset => xset})
  end

  def merge_ext(origin_extension, target_extension)
    merged_extension = {}
    
    origin_extension.each_pair do |key, values|
      if(values.is_a? Hash)
        image_merged_extension = merge_ext(values, target_extension)
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

  def intersect(xset)
    mappings = {}
    image = xset.all_items
    self.extension.each_key do |key|
      intersection_on_key = self.extension[key] & image
      mappings[key] = intersection_on_key if !intersection_on_key.empty?
    end
    mount_result_set("intersect", mappings, {:xset => xset})
  end

  def diff(xset)
    mappings = self.extension_copy
    xset.each do |item|
      mappings.each_key do |key|
        mappings[key].delete(item)
        mappings.delete(key) if mappings[key].empty?
      end
    end
    mount_result_set("diff", mappings, {:xset => xset})
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
