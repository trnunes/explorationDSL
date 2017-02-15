class Relation < Item
  attr_accessor :inverse

  def initialize(id, inverse=false)
    super(id)
    @inverse = inverse;
  end
  def relation?
    true
  end
  
  def domain
    
  end
  
  def range
  end
  
  def eql?(relation)
    super(relation) && (relation.inverse == self.inverse)
  end
  
  def hash
    @id.hash * inverse.hash
  end
  alias == eql?
  
end
