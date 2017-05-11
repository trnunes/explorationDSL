class Relation < Item
  attr_accessor :inverse

  def initialize(id, inverse=false)
    super(id)
    @inverse = inverse;
  end
  def relation?
    true
  end
  
  def domain(restriction)
    @server.domain(self, restriction)
  end
  
  def image(restriction)
    @server.image(self, restriction)
  end
  
  def text
    t = super().dup
    if(@inverse)
      t << " of"
    end
    t
  end
  
  def eql?(relation)
    super(relation) && (relation.inverse == self.inverse)
  end
  
  def hash
    @id.hash * inverse.hash
  end
  alias == eql?
  
end
