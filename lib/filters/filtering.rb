module Filtering
  
  def self.add_filter(filter)
    @@filters ||= []
    @@filters << filter
  end
  
  def self.eval_filters(set)
    filtered_extension = {}    
    current_set = set
    @@filters.each do |filter|
      
      filtered_extension = filter.eval(current_set)
      
      current_set = Xset.new do |s|
        s.server = current_set.server
        s.extension = filtered_extension
        s.resulted_from = current_set.resulted_from      
      end      
          
    end
    @@filters = []

    filtered_extension
  end
  
  def self.remove_from_domain(extension, item)
    extension.delete(item)
  end
  
  def self.remove_from_image(extension, item)
    
    extension.each do |ext_item, relations|
      if relations.is_a? Hash
        Filtering.remove_from_image(relations, item)
      else
        relations.delete(item)
      end      
      if relations.empty?
        extension.delete(ext_item)
      end
    end
  end
  
  class Filter

    def initialize(*args)     
    end
    
    def build_query_filter(set)
      

      if set.root?
        
        @filter = set.server.begin_filter
      else


        @filter = set.server.begin_filter do |f|
          f.union do |u|
            items = []
            if set.empty_image?
              items = set.domain
            else
              items = set.image
            end           
            items.each do |item|
              u.equals(item)
            end
          end
        end
        
      end
      @filter
    end
    
    def build_nav_query(set)
      if set.root?
        
        @nav_query = set.server.begin_nav_query
      else
        @nav_query = set.server.begin_nav_query do |nav_query|
          set.each do |item|
            nav_query.on(item)
          end
        end        
      end
      @nav_query
    end
    
    def eval(extension, set)

      if !@filter.nil?
        filtered_items = @filter.eval
        filtered_items_hash = {}
        filtered_items.each{|f| filtered_items_hash[f] = {}}
        if extension.empty?
          filtered_items.each do |item|
            extension[item] = {}
          end
        else
          if set.empty_image?
            extension.each_key do |item|
              extension.delete(item) if !filtered_items_hash.has_key?(item)
            end
          else
            extension.each_key do |key|
              extension[key].each do |relation_id, values|
                values.each do |value|                
                  if !filtered_items_hash.has_key?(value)
                    values.delete(value)                 
                    extension[key].delete(relation_id) if values.empty?
                    extension.delete(key) if extension[key].empty?            
                  end                      
                end
              end
            end            
          end
        end      
      end

      extension
    end
  end
end