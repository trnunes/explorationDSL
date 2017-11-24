class Edge
  attr_accessor :origin, :target, :annotations
  def initialize(origin, target, annotations = [])
    @origin, @target = origin, target
    @annotations = annotations
  end
  
  def eql?(edge)
    edge.origin == origin && edge.target == target
  end

  def hash
    origin.hash * target.hash
  end

  alias == eql?
  
  def inspect
    origin.item.inspect + " -> " + target.item.inspect
  end
  
end