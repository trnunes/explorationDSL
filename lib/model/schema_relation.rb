class SchemaRelation
  attr_accessor :id, :server, :inverse, :text, :parents, :index, :limit

  def initialize(id, inverse=false, server=nil)
    @id = id
    @text = @id
    @server = server
    @inverse = inverse
    @parents = []
    @index = Indexing::Entry.new('root')
  end
  def inverse?
    @inverse
  end
  def clone
    cloned_item = self.class.new(@id)
    cloned_item.text = @text
    cloned_item.server = @server
    cloned_item.inverse = @inverse
    cloned_item.index = @index.copy
    cloned_item
  end
  
  def shallow_clone
    cloned_item = self.class.new(@id)
    cloned_item.text = @text
    cloned_item.server = @server
    cloned_item.inverse = @inverse
    cloned_item
  end
  
  def domain()
    return @server.image(self) if @inverse
    @server.domain(self)
  end
  
  def image()
    return @server.domain(self) if @inverse
    @server.image(self)
  end
  
  def restricted_image(restriction, image_items = [], limit = -1)
    return [] if restriction.empty?
    # binding.pry
    if @inverse
      @inverse = false
      return restricted_domain(restriction, image_items, limit)
    end
    result_pairs = []
    
    query = @server.begin_nav_query(limit: limit) do |q|
      restriction.each do |item|
        q.on(item)
      end
      # binding.pry
      q.restricted_image(self.id, image_items)
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
  
  def restricted_domain(restriction, image_items = [], limit = -1)
    return [] if restriction.empty?
    if @inverse
      @inverse = false
      return restricted_image(restriction, image_items, limit)
    end
    
    result_pairs = []
    query = @server.begin_nav_query(limit: limit) do |q|
      restriction.each do |item|
        q.on(item)
      end
      q.restricted_domain(self.id, image_items)
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
  
  def text
    t = @text.dup
    if(@inverse)
      t + " of"
    else
      t
    end
  end
  
  def expression
    "SchemaRelation.new('" + @id + "', " + @inverse.to_s + ")"
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
