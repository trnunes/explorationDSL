require 'set'
module Xenumerable  

  
  #TODO implement
  def each_pair
  end

  def paginate(page_number, max_elements)

    @page = page_number
    @max_per_page = max_elements
  end
  
  def size
    extension.size
  end
  
  def page
    @page ||= 1
    @page
  end
  
  def [](item)
    self.extension[item]
  end
  
  def max_per_page
    @max_per_page ||= extension.keys.size
    @max_per_page 
  end
  
  def domain_number_of_pages
    if max_per_page == 0
      return 0
    end    
    (size/max_per_page.to_f).ceil
  end
  
  def image_number_of_pages
    if max_per_page == 0
      return 0
    end
    (image.size/max_per_page.to_f).ceil    
  end
  
  def limit

    if size == 0 || max_per_page == 0
      return 0
    end
    
    number_of_pages = (size.to_f/max_per_page.to_f).ceil
    if page == number_of_pages
      size
    else
      (max_per_page * page) - 1
    end    
  end
  
  def number_of_pages
    if max_per_page == 0
      return 0
    end
    
    if(page.nil?)
      1
    else
      (size.to_f/max_per_page.to_f).ceil
    end
  end
  
  def offset
    (page - 1) * max_per_page
  end
  
  def image(item = nil)
    if(item.nil?)
      extension.values
    else
      extension[item]
    end    
  end
  
  def trace_image(item, target_sets)
    # puts "TARGET SET ORIGIN: " << target_sets.inspect
    path_image = Xset.new{|s| s.extension = target_sets.shift.relation_index[item]}

    while(!target_sets.empty?)
      # puts "TARGET SET: " << target_sets.inspect
      target_set = target_sets.shift
      


      path_image.last_level.each do |level_items|
        level_items.keys.each do |key|

          values = level_items[key]
          if(target_set.relation_index.has_key? key)
            values.merge!(target_set.relation_index[key])
          else
            if(key.is_a? Xsubset)
              key.each do |subset_item|

                if(target_set.relation_index.has_key? subset_item)
                  level_items.delete(key)                  
                  level_items[subset_item] ||= {}
                  level_items[subset_item].merge!(target_set.relation_index[subset_item])                  
                end
              end
            end
          end
        end

      end
    end
    path_image.extension     
  end
  
  def has_subset?(xsubset)
    if xsubset == self
      return true
    end
    get_level(xsubset.level).each do |level_subset|
      if level_subset == xsubset.extension
        return true
      end
    end
    return false
  end
  
  def all_images(hash)
    image = Set.new
    hash.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        if values.is_a? Hash
          iamge += all_images(values)
        else
          values.each do |v|
            image << v
          end          
        end        
      end
    end    
    image
  end
  
  def domain(paginated, level=1)
    @domain ||= get_level(level).map{|items_hash| items_hash.keys}.flatten
    if paginated
      @domain[offset..limit]
    else
      @domain
    end    
  end
  
  
  def restricted_domain(set, &block)
    restricted_domain_set = Set.new()
    set.each do |item|
      domain_keys = domain(false)
      domain_keys.each do |key|
        images = images_for(key, extension)
        if images.include?(item)
          if block_given?
            yield(key)
          end
          restricted_domain_set << key
        end
      end
    end
    restricted_domain_set
  end
  
  def each_domain_paginated(&block)
    domain(true).each &block if block_given?
    Set.new(domain(true))
  end
  
  def each_domain(&block)
    domain(false).each &block if block_given?
    Set.new(domain(false))
  end
  
  def restricted_image(set, &block)
    image = Set.new
    set.each do |item|
      if extension.has_key? item
        image.merge(images_for(item, extension))
      end
    end
    image.each &block if block_given?
    image
  end
  
  def each_image(&block)
    image[offset..limit(image.size)].each &block if block_given?
    Set.new(image[offset..limit(image.size)])
  end
  
  def each_paginated(&block)
    domain(true).each &block
  end

  def contains_item?(hash, item_to_search)
    has_item = false



    hash.each do |key, values|
      if key == item_to_search
        has_item =  true
      else
        if values.respond_to? :keys
          has_item = contains_item?(values, item_to_search)
        else
          values = [values] if !values.respond_to?(:each)
          values.each do |value|

            if value == item_to_search

              has_item = true
              break
            else
              if(value.respond_to? :keys)
                has_item = contains_item?(value, item_to_search)
              end
            end
          end
        end
      end
      return true if has_item        
    end

    return has_item
  end
  
  def each_entity(level=1, &block)




    entities = []
    get_level(level).each do |item_hash|
      if block_given?
        
        item_hash.each do |item, values|
          if (item.is_a?(Entity) || item.is_a?(Relation) || item.is_a?(Type))
            

            yield(item) 
            entities << item
          end
          
        end
      end
      
    end

  end
  
  def each(level=1, &block)
    domain(false, level).each &block   
  end
  
  def entities(level=1)

    domain(false, level).select{|item| item.is_a?(Entity) || item.is_a?(Relation) || item.is_a?(Type)}
  end
  
  def entities_of_level(level=1)
    level = get_level(level)
    level.delete_if do |items_hash| 
      items_hash.delete_if{|key, values| !(key.class == Entity || key.class == Relation || key.class == Type)}.empty?
    end
    level
  end
  
  def items_of_level(level=1)
    level = get_level(level)
    level
  end
  

  
  def each_item(&block)
    items_hash = {}
    each_domain_paginated do |item|
      if block_given?
        yield(item, extension[item])
      else
        items_hash[item] = extension[item]
      end
    end
    items_hash.each &block
  end

  def all_items(&block)
    @page = nil
    each &block
  end
  
  def <<(entity)
    @extension[entity] = {}
  end
  
  def size
    self.extension.keys.size
  end
  
  def first
    self.extension.keys.first
  end 
  
  def remove(item)
    extension.each_key do |key|
      extension.delete(key) if extension[key].include?(item)
    end
    self
  end  
  
  def images_for(domain, extension)
    imediate_relations = extension[domain]
    image_set = Set.new
    imediate_relations.each do |relation_key, relation_image|
      if relation_image.is_a? Hash
        relation_image.each do |nested_relation_key, nested_relation_image|
          image_set.merge(images_for(nested_relation_key, nested_relation_image))
        end
      else
        image_set.merge(relation_image)
      end      
    end
    image_set
  end
  
  def empty_image?
    relations = extension.values
    relations.reject!{|v| v.empty?}
    relations.empty?    
  end
  
  def each_level(level_items = nil, &block)
    items_to_return = Set.new
    next_level_items = Set.new
    if level_items.nil?
      level_items = Set.new

      extension.each_key do |key|
        next_level_items << [key, extension] if !HashHelper.empty_values?(extension)
        
      end
      items_to_return << extension
    else
      level_items.each do |pair| 
        hash_key = pair[0]
        hash_to_address = pair[1]

        items_to_return << hash_to_address[hash_key]

        if !HashHelper.empty_values?(hash_to_address[hash_key])
          hash_to_address[hash_key].each_key do |key|
            next_level_items << [key, hash_to_address[hash_key]]
          end        
        end
      end
    end
    
    
    yield(items_to_return) if block_given? && !items_to_return.empty?
  
    if(!next_level_items.empty?)
      each_level(next_level_items, &block)
    end
  end

  def select_level(level)
    get_level(level)
  end
    
  def get_item(items = @extension.keys, item_to_get)
    return if items.nil?
    items.each do |item|
      if item == item_to_get
        return item
      else
        returned_item = get_item(item.children, item_to_get)
        return returned_item if !returned_item.nil?
      end
    end
    return nil    
  end
  
  def get_level(level)
    level_count = 0
    level_items = Set.new

    each_level do |items|
      level_count += 1
      level_items = items if level_count == level
    end
    level_items
  end
  
  def last_level()
    last_level_items = nil
    each_level{|items| last_level_items = items}
    last_level_items
  end
  
  def count_levels
    count = 0
    each_level{|items| count += 1}
    count
  end
    
end
