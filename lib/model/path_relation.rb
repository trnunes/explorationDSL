class PathRelation
  attr_accessor :id, :server, :inverse, :text, :relations, :limit

  def initialize(relations, limit=nil)
    @limit = limit
    @relations = relations
  end
  
  def can_fire_path_query
    are_all_schema_relations = (@relations.select{|r| r.is_a? SchemaRelation}.size == @relations.size)

    are_all_single_direction = (@relations.map{|r| r.inverse}.uniq.size == 1)

    # is_single_server = (@relations.map{|r| r.server}.uniq.size == 1)
    # (are_all_schema_relations && are_all_single_direction && s_single_server)
    # binding.pry
    (are_all_schema_relations && are_all_single_direction)
  end
  
  def domain()
    @relations.first.domain
  end
  
  def server=(server)
    @server = server
    @relations.each{|r| r.server = server}
  end
  def image()
    @relations.last.image
  end
  
  def mixed_path_restricted_image(items, image_items, limit)
    relations = @relations
    result_pairs = []

    result_pairs = items.map{|i| Pair.new(i, i)}

    relations.each do |r|
      
      restriction = result_pairs.map{|pair| pair.image}
      @limit ||= restriction.size
      partial_pairs = r.restricted_image(Set.new(restriction[0..@limit]), image_items, limit)
      partial_pairs_hash = {}
      partial_pairs.each do |pair| 
        if(!partial_pairs_hash.has_key? pair.domain)
          partial_pairs_hash[pair.domain] = []
        end
        partial_pairs_hash[pair.domain] << pair.image
        
      end
      
      new_result_pairs = []
      result_pairs.each do |pair|
        if(partial_pairs_hash.has_key? pair.image)
          partial_pairs_hash[pair.image].each do |next_image|
            new_result_pairs << Pair.new(pair.domain, next_image)
          end
        end
      end
      result_pairs = new_result_pairs

    end
    result_pairs
  end
  
  def mixed_path_restricted_domain(items)
    relations = @relations
    result_pairs = []
    inverse = (@args[:direction] == "backward")
    result_pairs = items.map{|i| Pair.new(i, i)}
    relations.each do |r|
      
      partial_pairs = r.restricted_domain(Set.new(result_pairs.map{|pair| pair.image}))
      partial_pairs_hash = partial_pairs.map{|pair| [pair.domain, pair.image]}.to_h
      
      result_pairs.each do |pair|
        if(partial_pairs_hash.has_key? pair.image)
          pair.image = partial_pairs[pair.image]
        else
          result_pairs.delete(pair)
        end
      end
    end
    result_pairs
  end
    
  def schema_restricted_image(restriction, image_items, limit)
    if(@relations.first.inverse)
      @relations.first.inverse = false
      return schema_restricted_domain(restriction, image_items, limit)
    end
    server = @relations.first.server
    result_pairs = []
    query = server.begin_nav_query(limit: limit) do |q|
      restriction.each do |item|
        q.on(item)
      end
      q.restricted_image(@relations.map{|r| r.id}, image_items)
    end
    # binding.pry
    partial_path_results = query.execute
    # binding.pry
    partial_path_results.each do |item, relations_hash|
      relations_hash.each do |key, values|
        values.each do |v|
          result_pairs << Pair.new(item, v)
        end
      end
    end
    result_pairs
  end
  
  def schema_restricted_domain(restriction, image_items, limit)
    if(@relations.first.inverse)
      @relations.first.inverse = false
      return schema_restricted_image(restriction, image_items, limit)
    end
    
    result_pairs = []
    query = @server.begin_nav_query(limit: limit) do |q|
      restriction.each do |item|
        q.on(item)
      end
      q.restricted_domain(@relations.map{|r| r.id})
    end
    partial_path_results = query.execute
    
    partial_path_results.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        values.each do |value|
          result_pairs << Pair.new(value, item)
        end
      end  
    end
    result_pairs
  end
  
  def restricted_image(restriction, image_items = [], limit)
    if can_fire_path_query
      schema_restricted_image(restriction, image_items, limit)
    else
      mixed_path_restricted_image(restriction, image_items, limit)
    end
  end
  
  def restricted_domain(restriction)
    if can_fire_path_query
      schema_restricted_domain(restriction)
    else
      mixed_path_restricted_domain(restriction)
    end
  end
      
  def text
    @relations.map{|r| r.text}.join("/")
  end
  
  def eql?(relation)
    (self.id == relation.id) && (relation.inverse == self.inverse)
  end
  
  def hash
    @id.hash * inverse.hash
  end
  
  alias == eql?
  
end
