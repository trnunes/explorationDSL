require 'set'
module Xenumerable  

  
  #TODO implement
  def each_pair
  end

  def paginate(page_number, max_elements)

    @page = page_number
    @max_per_page = max_elements
    if extension.empty? && root?
      server.each_item do |item| 
        extension[item] = {}
      end
    end    
  end
  
  def size
    if(root?)
      server.size
    else
      extension.size
    end
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
  
  def image    
    @image ||= all_images(extension)
    @image
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
  
  def domain(paginated)
    @domain ||= extension.keys
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
    if root?
      server.each_item do |item| 
        extension[item] = {}
      end
    end
    domain(true).each &block
  end
  
  def each(&block)
    if root?
      server.each_item do |item| 
        extension[item] = {}
      end
    end
    domain(false).each &block   
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
    
end
