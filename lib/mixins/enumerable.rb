require 'set'
module Xenumerable  

  
  #TODO implement
  def each_pair
  end

  def paginate(page_number, max_elements, image_paginate)
    @paginate_image = image_paginate
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
  
  def paginate_image?
    @paginate_image ||= false
    @paginate_image
  end
  
  def max_per_page
    if paginate_image?
      @max_per_page ||= image.size
    else
      @max_per_page ||= domain.size
    end
    @max_per_page 
  end
  
  def domain_number_of_pages
    if max_per_page == 0
      return 0
    end    
    (domain.size/max_per_page.to_f).ceil
  end
  
  def image_number_of_pages
    if max_per_page == 0
      return 0
    end
    (image.size/max_per_page.to_f).ceil    
  end
  
  def limit(total_size)
    if total_size == 0 || max_per_page == 0
      return 0
    end
    
    number_of_pages = (total_size.to_f/max_per_page.to_f).ceil
    if page == number_of_pages
      total_size
    else
      (max_per_page * page) - 1
    end    
  end
  
  def number_Of_pages
    if max_per_page == 0
      return 0
    end
    
    if(page.nil?)
      1
    else
      (image.size.to_f/max_per_page.to_f).ceil
    end
  end
  
  def offset
    (page - 1) * max_per_page
  end
  
  def image
    @image ||= extension.values.map{|relation| relation.values.map{|value| value.to_a}.flatten}.flatten.uniq
    puts "IMAGE: " << @image.inspect
    @image
  end
  
  def domain
    @domain ||= extension.keys
    @domain
  end
  
  def restricted_domain(set, &block)
    restricted_domain_set = Set.new()
    set.each do |item|
      domain_keys = domain()
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
  
  def each_domain(&block)
    domain[offset..limit(domain.size)].each &block if block_given?
    Set.new(domain[offset..limit(domain.size)])
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
  
  def each(&block)
    if root?
      server.each_item do |item| 
        extension[item] = {}
      end
    end
    
    if empty_image?
      domain.each &block
    else
      image.each &block          
    end
    
  end

  def all_items(&block)
    @page = nil
    each &block
  end
  
  def <<(entity)
    @extension[entity] = {}
  end
  
  def size
    self.each_image.size
  end
  
  def first
    self.each_image.to_a.first
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
