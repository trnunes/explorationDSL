class ComputedRelation
  attr_accessor :id, :text, :pairs, :server
  def initialize(id)
    @id = id
    @pairs = []
  end
  
  def domain()
    Set.new(@pairs.map{|p| p.domain})
  end
  
  def image()
    Set.new(@pairs.map{|p| p.image})
  end
  
  def default?
    @id.to_s.empty?
  end
  
  def restricted_image(restriction)
    restriction_set = Set.new(restriction)

    @pairs.select{|pair| restriction_set.include?(pair.domain)}
  end
  
  def restricted_domain(restriction)
    restriction_set = Set.new(restriction)

    @pairs.select{|pair| restriction_set.include?(pair.image)}
  end
  
  def add_pair(pair)
    pair.relation = self.id
    @pairs << pair
  end
  
  def each_pair(&block)
    if block_given?
      @pairs.each &block
    else
      @pairs
    end
  end
  
  def eql?(relation)
    (self.id == relation.id)
  end
  
  def hash
    @id.hash
  end
  
  alias == eql?
  

end