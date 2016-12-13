class Filter
  attr_accessor :query, :expression
  def initialize(set)
    @set = set  
    
    @query = set.server.begin_filter do |q|
      q.union do |u|
        @set.each do |item|        
          u.equals(item)
        end
      end
    end
    
    @actual_extension = Marshal.load(Marshal.dump(@set.extension))
    @matched_items = []
    @access_data_server = false
    @expression = "{|f| f"   
  end
    
  def equals(relation=nil, object)
    if(relation.nil?)
      @set.each_image.select{|item| !(item.eql?(object))}.each do |removed_item|
        remove_from_extension(removed_item)
        @expression << ".equals(\"#{object.to_s}\")"
      end      
    else
      @access_data_server = true
      @query.relation_equals(relation, object)
      @expression << ".equals(\"#{relation.to_s}\", \"#{object.to_s}\")"
    end    
    self
  end
  
  def match(relation=nil, pattern)
    if(relation.nil?)
      @set.each_image.select{|item| item.to_s.match(/#{pattern}/).nil?}.each do |removed_item|
        
        
        remove_from_extension(removed_item)        
        @expression << ".match(\"#{pattern}\")"
      end
    else
      @query.relation_regex(relation, pattern)
      @access_data_server = true
      @expression << ".match(\"#{relation.to_s}\", \"#{pattern}\")"
    end
    self
  end
  
  def keyword_match(relation=nil, pattern)
    filtered_items = Set.new
    
    relations_query = @set.server.begin_nav_query do |nav_query|
      @set.each do |item|
        nav_query.on(item)
      end
      nav_query.find_relations
    end
    
    keep_item = false
    
    relations_query.execute.each_pair do |item, relations|
      keep_item = false

      
      
      relations.values.each do |related_item|
        pattern.each do |keyword_pattern|
          if keyword_pattern.respond_to? :each
            keyword_pattern.each do |disjunctive_keyword|
              keep_item = true if related_item.to_s.include?(disjunctive_keyword)
            end
          else
            keep_item = false if !related_item.to_s.include?(keyword_pattern)
          end
        end
      end
      
      remove_from_extension(item) if !keep_item
      
    end   
    self
  end
  
  def contains_one(relation, values)
    count = 0 
    
    @query.union do |u|
      values.each do |value|
        u.relation_equals(relation, value) 
      end
    end
    
    @access_data_server = true
    self
  end
  
  def contains_all
    
  end
  
  def in_range(relation, min, max)    
    @query.filter_by_range(relation, min, max)
    @access_data_server = true
    
    self
  end
  
  def eval
    if @access_data_server
      filtered_items = @query.eval     
      
      @actual_extension.each_key do |key|
        @actual_extension[key].each do |value|
          @actual_extension[key].delete(value) if !filtered_items.include?(value)
        end
        @actual_extension.delete(key) if @actual_extension[key].empty?
      end
    end
        
    @actual_extension
  end
  
  def remove_from_extension(item)    
    @actual_extension.each_key do |key|
      @actual_extension[key].delete(item)
      @actual_extension.delete(key) if @actual_extension[key].empty?
    end    
  end
end