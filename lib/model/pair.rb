class Pair
  attr_accessor :domain, :image, :relation
  
  def initialize(domain, image, relation = '')
    @domain = domain
    @image = image
    @relation = relation
  end
  
  def eql?(pair)
    self.class == pair.class && @domain == pair.domain && @image == pair.image && relation == pair.relation
  end
  
  def hash
    @id.hash
  end
  
  def to_s
    # binding.pry
    "(" + @relation + ": " +  (@domain.is_a?(Xpair::Literal)? @domain.value.to_s : @domain.id) + ", " + (@image.is_a?(Xpair::Literal)? @image.value.to_s : @image.id) + ")"
  end
  
  def inspect
    to_s
  end
end