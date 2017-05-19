class SchemaRelation
  attr_accessor :id, :server, :inverse, :text

  def initialize(id, server=nil, inverse=false)
    @id = id
    @server = server
    @inverse = inverse
    
  end
  
  def domain()
    @server.domain(self)
  end
  
  def image()
    @server.image(self)
  end
  
  def restricted_image(restriction)
    return [] if restriction.empty?
    result_pairs = []
    query = @server.begin_nav_query do |q|
      restriction.each do |item|
        q.on(item)
      end
      q.restricted_image(self.id)
    end
    partial_path_results = query.execute
    
    partial_path_results.each do |item, relations_hash|
      relations_hash.each do |key, values|
        values.each do |v|
          result_pairs << Pair.new(item, v)
        end
      end
    end

    result_pairs
  end
  
  def restricted_domain(restriction)
    return [] if restriction.empty?
    result_pairs = []
    query = @server.begin_nav_query do |q|
      restriction.each do |item|
        q.on(item)
      end
      q.restricted_domain(self.id)
    end
    partial_path_results = query.execute
    
    partial_path_results.each do |item, relations_hash|
      relations_hash.each do |relation, values|
        values.each do |value|
          result_pairs << Pair.new(value, item)
        end
      end  
    end
    binding.pry

    result_pairs
  end
  
  def text
    t = @text.dup
    if(@inverse)
      t << " of"
    end
    t
  end
  
  def to_s
    self.id
  end
  
  def eql?(relation)
    (self.id == relation.id) && (relation.inverse == self.inverse)
  end
  
  def hash
    @id.hash * inverse.hash
  end
  
  alias == eql?
  
end
