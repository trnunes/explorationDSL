module Filtering
  
  def self.add_filter(filter)
    @@filters ||= []
    @@filters << filter
  end
  
  def self.eval_filters(set)
    filtered_extension = {}    
    current_set = set
    # begin
      @@filters.each do |filter|
        # binding.pry
        filtered_extension = filter.eval(current_set)
      
        current_set = Xset.new do |s|
          s.server = current_set.server
          s.extension = filtered_extension
          s.resulted_from = current_set.resulted_from      
        end      
          
      end
    # rescue Exception => e
    #   # binding.pry
    #   self.clear
    #   raise "It is not possible to apply the filters due to an internal error: (#{e.to_s})!"
    # end
    self.clear
    filtered_extension
  end
  
  def self.expression
    @@filters.map{|f| f.expression}.join
  end
  
  def self.clear
    @@filters = []
  end
  
  class Filter

    def initialize(*args)     
    end
    
    def build_query_filter(set)
      @filter = set.server.begin_filter do |f|
        f.union do |u|
          set.each_item do |item|
            u.equals(item)
          end
        end
      end        

      @filter
    end
    
    def build_nav_query(set)
      @nav_query = set.server.begin_nav_query do |nav_query|
        set.each_item do |item|
          nav_query.on(item)
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