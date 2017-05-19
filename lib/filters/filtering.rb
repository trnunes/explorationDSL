module Filtering
  
  def self.add_filter(filter)
    @@filters ||= []
    @@filters << filter
  end
  
  def self.get_filters
    @@filters
  end
  
  def self.set_server(server)
    @@server = server
  end  
  
  def self.prepare(items, server)
    @@filters.each do |f| 
      f.server = server
      f.prepare(items, server)
    end
  end
  
  def self.eval_filters(item)
        
    is_filtered = true
    @@filters.each do |f|
      is_filtered = is_filtered && f.filter(item)
    end
    is_filtered
  end
  
  def self.expression
    @@filters.map{|f| f.expression}.join
  end
  
  def self.clear
    @@filters = []
  end
  
  class Filter
    attr_accessor :server

    def initialize(*args)     
    end
    

    
    def build_query_filter(items)
      @filter = server.begin_filter do |f|
        f.union do |u|
          items.each do |item|
            u.equals(item)
          end
        end
      end      

      @filter
    end
    
    def build_nav_query(items)
      @nav_query = @server.begin_nav_query do |nav_query|
        items.each do |item|
          nav_query.on(item)
        end
      end

      @nav_query
    end
    
    def filter(item)
      return false
    end
  end
end