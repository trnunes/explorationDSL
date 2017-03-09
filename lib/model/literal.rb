class Literal
  include Xpair::Graph
  attr_accessor :value
  def initialize(value)
    @value = value
  end
  
  def eql?(obj)
    self.class == obj.class && @value == obj.value
  end
  
  def hash
    @value.hash
  end
  
  def to_s
    @value.to_s
  end
  alias == eql?
  

end