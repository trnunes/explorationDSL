require 'set'
module Xenumerable  

  
  #TODO implement
  def each_pair
  end

  def paginate(max_elements)
    @max_per_page = max_elements
  end
  
  def size
    count = 0
    images = Set.new
    if(!@count)
      keys.each do |key|
        # binding.pry
        image(key).each do |img|
          if(img.is_a? Xsubset)
            count += img.size
          else
            images << img
          end
          # binding.pry
        end
      end
    end

    count + images.size
  end
  
  def page
    @page ||= 1
    @page
  end
  
  def [](item)
    self.extension[item]
  end
  
  def []=(item, element)
    self.extension[item] = element
  end
  
  def has_key?(item)
    self.extension.has_key? item
  end
  def max_per_page
    @max_per_page ||= size
    @max_per_page 
  end
    
  def image_number_of_pages
    if max_per_page == 0
      return 0
    end
    (each_image.size/max_per_page.to_f).ceil    
  end
  
  def keys
    self.extension.keys
  end
  
  def limit

    if size == 0 || max_per_page == 0
      return 0
    end
    number_of_pages = (size.to_f/max_per_page.to_f).ceil


    if page.to_f == number_of_pages
      size
    else
      (max_per_page * page) - 1
    end    
  end

  def count_pages
    if max_per_page == 0
      return 0
    end
    
    if(page.nil?)
      1
    else
      (size.to_f/max_per_page.to_f).ceil
    end
  end
  
  def many_to_one?
    !self.extension.keys.first.nil? && (self.extension.keys.first.is_a?(Xsubset) && self.extension.values.first.is_a?(Hash))
  end
  
  def many_to_many?
    !self.extension.keys.first.nil? && (self.extension.keys.first.is_a?(Xsubset) && self.extension.values.first.is_a?(Xsubset))
  end
  
  def offset
    (page - 1) * max_per_page
  end
  
  def image(item = nil)
    images = []
    if(item.nil?)
      if(HashHelper.empty_values?(extension))
        images = extension.keys
      else
        images = extension.values.map{|value| value.keys}.flatten
      end
    else
      if(HashHelper.empty_values?(extension))
        if(self.has_key?(item))
          images = [item]
        end
      else
        # binding.pry
        if(extension[item].is_a? Hash)
          images = extension[item].keys
        else
          images << extension[item]
        end
        
      end
      # binding.pry
    end 
    if(!images.first.is_a? Xpair::Literal)
      images.uniq!
    end
    images.compact!
    return images  
  end
  
  def trace_image_items(item, target_sets)
    
    image_set = trace_image(item, target_sets)
    image_set.map do |image|
      if image.is_a? Xsubset
        image.keys
      else
        image
      end
    end.flatten
  end
  
  def image_items(domain_item)
    image_set = self.image(domain_item)
    image_set.map do |image|
      if image.is_a? Xsubset
        image.keys
      else
        image
      end
    end.flatten
    
  end
  
  def horizontal?
    if(self.intention)
      self.intention.horizontal?
    else
      false
    end
  end
  
  def trace_domains(item)
    images_array = []

    local_domains = self.domain(item)

    # binding.pry
    
    # images_array << [self.id, local_domains].flatten unless local_domains.empty?
  
    if self.resulted_from

      origin_set = self.resulted_from
      
      while(origin_set)
        origin_set_domains = []
        images_array.unshift [origin_set.id, local_domains].flatten unless local_domains.empty?

        local_domains.each do |local_domain|
          # binding.pry
          origin_set_domains += origin_set.domain(local_domain)
          # binding.pry
        end
        local_domains = origin_set_domains.flatten
        origin_set = origin_set.resulted_from
      end
    end

    return images_array
  end
  
  def trace_image(items, target_sets)
    if !items.respond_to? :each
      items = Set.new([items])
    end
    images = Set.new
      
    items.each do |item|
      images += self.image(item)
    end
    
    if(!target_sets.empty?)
      target_set = target_sets.shift
      if(target_set.horizontal?)
        images = items
      end
      return target_set.trace_image(images, target_sets)
    end
    return images
  end
  
  # def trace_image(item, target_sets)
  #
  #   images = Set.new
  #   source_images = Set.new([item])
  #
  #
  #   while(!target_sets.empty?)
  #
  #     target_set = target_sets.shift
  #
  #
  #     if !(target_set.many_to_many? || target_set.many_to_one?)
  #
  #       source_images = source_images.map do |image|
  #         if image.is_a? Xsubset
  #           image.keys
  #         else
  #           image
  #         end
  #       end.flatten
  #     end
  #
  #     images = Set.new
  #
  #
  #
  #     # if(item.id == "http://data.semanticweb.org/workshop/cold/2011/proceedings")
  #     #   #binding.pry
  #     # end
  #
  #     source_images.each do |local_image|
  #
  #
  #
  #       if target_set.has_key? local_image
  #         if target_set[local_image].is_a? Hash
  #           if(HashHelper.empty_values?(target_set[local_image]))
  #             images += target_set[local_image].keys
  #           else
  #             target_set[local_image].values.each do |v|
  #               if(HashHelper.empty_values?(v))
  #                 images += v.keys
  #               else
  #                 images += v.values
  #               end
  #             end
  #           end
  #
  #         elsif target_set[local_image].is_a? Xsubset
  #
  #           if target_set[local_image].count_levels > 1
  #             images += target_set[local_image].each_image
  #           else
  #             images << target_set[local_image]
  #           end
  #
  #         else
  #           images << local_image
  #         end
  #       end
  #     end
  #
  #
  #     source_images = images
  #   end
  #
  #   source_images
  # end
  
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
  
  def domain(item)
    domains = []
    if HashHelper.empty_values?(self.extension) && self.has_key?(item)
      domains << item
      return domains
    end
    if(self.horizontal?)
      if(self.has_key?(item))
        domains << item
      end
      return domains
    end

    self.keys.each do |domain_key|      
      if self[domain_key] == item
        domains << domain_key 
      else
        if self[domain_key].is_a? Xsubset

          search_results = []
          if item.is_a? Xsubset

            subset = self[domain_key].get_subset(item.id)

            search_results << subset unless subset.nil?
          else
            self[domain_key].search_items([item], search_results)
          end
          if !search_results.empty?
            domains << domain_key
          end
        else
          if(HashHelper.contains?(self[domain_key], item))
            domains << domain_key
          end

        end
      end
    end
    domains
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
  
  def each_image(options = {}, &block)
    @page = options[:page]
    images = Set.new


    enumerable = []


    enumerable = last_level

    enumerable.each do |item|
      # #binding.pry
      if item.is_a? Hash
        if(HashHelper.empty_values?(item))
          images += item.keys
        else
          item.values.each do |value_hash|
            if(HashHelper.empty_values?(value_hash))
              images += value_hash.keys
            else
              images += value_hash
            end
          end

        end

      else
        images << item
      end
    end
    if(options[:page])
      images = images.to_a[offset..limit]
    end
    if block_given?
      images.each &block
    end
    images
  end
  
  def has_subsets?
    self.each_image.first.is_a? Xsubset
  end
  
  def each_entity(&block)
    entities = Set.new
    each_item{|item| entities << item if item.is_a?(Item)}

    entities.each &block
  end
  
  def each_item(&block)
    images = Set.new


    last_level.each do |item|
      if item.is_a? Xsubset
        images += item.extension.keys
      elsif item.is_a? Hash
        if(HashHelper.empty_values?(item))
          images += item.keys
        else
          item.values.each do |v|
            images += v.keys
          end
        end
      else
        
        images << item
      end
      
    end
    if block_given?
      images.each &block
    end
    images
  end
  
  def each_paginated(&block)
    domain(true).each &block
  end
  
  def search_items(items, search_results)
    items.each do |item|
      if self.has_key? item
        search_results << item
      elsif(self.is_a? Xsubset)
        search_results << item if self.key == item
      end
    end
    each_level do|level_items| 
      puts "--------LEVEL---------------- #{self.id}"
      # binding.pry
      level_items.each do |item|
        puts
        # binding.pry
        if item.is_a? Xsubset

          item.search_items(items, search_results)
        elsif item.is_a? Hash
          puts item.inspect
          (item.keys & items).each do |item_key|
            search_results << item_key
          end
        else
          search_results << item if items.include?(item)
        end
        # binding.pry
      end
    end
  end
  
  def search_subsets(subsets, selected_subsets)
    if has_subsets?
      each_level do |level_items|
        if level_items.first.is_a? Xsubset
          level_items.select{|item| !selected_subsets.select{|s| s.id == item.id}.empty?}.each do |subset|
            selected_subsets << subset
          end
        end
      end
    end    
  end
  
  def get_subset(subset_id)
    if has_subsets?
      each_level do |level_items|
        if level_items.first.is_a? Xsubset
          level_items.each do |level_item|
            return level_item if level_item.id == subset_id
          end
        end
      end
    end        
  end

  def get_item(item_id)

    each_item do |item|

      if item.is_a? Xpair::Literal
        return item if item.to_s == item_id
      else
        return item if item.id == item_id
      end
    end
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
  
  # def each_entity(level=1, &block)
  #
  #
  #
  #
  #   entities = []
  #   get_level(level).each do |item_hash|
  #     if block_given?
  #
  #       item_hash.each do |item, values|
  #         if (item.is_a?(Entity) || item.is_a?(Relation) || item.is_a?(Type))
  #
  #
  #           yield(item)
  #           entities << item
  #         end
  #
  #       end
  #     end
  #
  #   end
  #
  # end
  #
  def each(&block)
    each_item &block   
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
  
  def empty?
    return true if self.extension.nil?
    
    return self.extension.empty?
  end
  
  def remove_item(item)


    searched_item = nil
    extension_copy = self.extension

    self_copy = self
    count = 0
    extension_copy.keys.each do |key|
      values = extension_copy[key]



      if (item == key || item == values)


        extension_copy.delete(key)

      else
        if values.is_a? Xsubset
          values.remove_item(item)
        elsif values.is_a? Hash
          values.delete(item)
        end
      end
      # extension_copy.delete(key) if extension_copy.has_key?(key) && extension_copy[key].empty?

    end
  end
  
  def all_items(&block)
    @page = nil
    each &block
  end
  
  def <<(entity)
    @extension[entity] = {}
  end
  
  
  def first
    each_image.first
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
      if extension.nil?
        return items_to_return
      end
      


      level_items = extension.keys

      if !HashHelper.empty_values?(extension)
        next_level_items = extension.values
      end
      


    end
    
    items_to_return = level_items

    level_items.each do |level_item|
      if level_item.is_a? Xsubset
        if !HashHelper.empty_values?(level_item.extension)
          next_level_items += level_item.extension.values
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
    last_level_items = []
    each_level do |items| 


      last_level_items = items
    end
    last_level_items
  end
  
  def count_levels
    count = 0
    each_level{|items| count += 1}
    count
  end
    
end
