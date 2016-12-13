require 'set'
module Xenumerable  

  
  #TODO implement
  def each_pair
  end

  def paginate(page, max_per_page)
    @page = page
    @max_per_page = max_per_page
    if extension.empty? && root?
      server.each_item do |item| 
        extension[item.id] = Set.new([item])
      end
    end

    @paginated_domain ||= extension.keys.to_a 
    @paginated_image ||= extension.values.map{|img_set| img_set.to_a}.flatten.uniq
    
    
  end
  def size
    if(root?)
      server.size
    else
      extension.size
    end
  end
  def page
    @page
  end  
   
  def domain_number_of_pages
    (@paginated_domain.size/@max_per_page.to_f).ceil
  end
  
  def image_number_of_pages
    (@paginated_image.size/@max_per_page.to_f).ceil    
  end
  
  def limit(total_size)
    number_of_pages = (total_size.to_f/@max_per_page.to_f).ceil
    if @page == number_of_pages
      total_size - 1
    else
      (@max_per_page * @page) - 1
    end    
  end
  
  def number_Of_pages
    if(@page.nil?)
      1
    else
      (@paginated_image.size.to_f/@max_per_page.to_f).ceil
    end
  end
  def offset
    (@page - 1) * @max_per_page
  end
  
  
  def each_domain(set = nil, &block)
    domain = Set.new
    if extension.empty?
      each{|f|}
    end

    if set.nil?
      if(!@page.nil?)
        return @paginated_domain[offset()..limit(@paginated_domain.size)]
      else
        return extension.keys
      end      
    else
      set.each do |item|
        if(!@page.nil?)
          domain_keys = @paginated_domain[offset()..limit(@paginated_domain.size)]
        else
          domain_keys = extension.keys
        end         
        domain_keys.each do |key|
          images = images_for(key, extension)
          if images.include?(item)
            if block_given?
              yield(key)
            end
            domain << key
          end
        end
      end
    end    
    domain
  end
  
  def each_image(set = nil, &block)
    image = Set.new
    
    if set.nil?
      if @page.nil?
        image += extension.values.map{|img_set| img_set.to_a}.flatten
      else
        image += @paginated_image[offset..limit(@paginated_image.size)]
      end
      
    else
      set.each do |item|
        if extension.has_key? item
          image.merge(images_for(item, extension))
        end
      end      
    end
    
    image.each &block if block_given?
    image
  end
  
  def each(&block)
    if(extension.empty? && root?)
      server.each_item do |item| 
        extension[item.id] = Set.new([item])
      end
    end
      each_image.each &block
  end

  def all_items(&block)
    @page = nil
    each &block
  end
  
  def <<(entity)
    @extension[entity.id] = Set.new([entity])
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
    imediate_img = extension[domain]
    image = Set.new
    if imediate_img.is_a? Hash
      imediate_img.each_key do |key|
        image.merge(images_for(key, imediate_img))
      end
      return image
    elsif imediate_img.respond_to? :each
      return imediate_img
    else
      return Set.new
    end
  end  
  
end
