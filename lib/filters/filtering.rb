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
  
  class Filter

    def initialize(*args)     
    end
    
    def build_query_filter(set)
      

      if set.root?        
        @filter = set.server.begin_filter
      else
        @filter = set.server.begin_filter do |f|
          f.union do |u|
            set.each do |item|
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
          extension.each_key do |item|
            extension.delete(item) if !filtered_items_hash.has_key?(item)
          end
        end      
      end
      extension
    end
  end
end