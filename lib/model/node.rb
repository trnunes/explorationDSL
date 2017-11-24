class Node
  attr_accessor :item, :parent_edge, :children_edges, :annotations
  
  def initialize(item, annotations = [])
    @children_edges = []
    @annotations = annotations
    @item = item
  end
  
  def annotate(annotation)
    @annotations << annotation
  end
  
  def parent
    parent = nil
    if(@parent_edge)
      parent = @parent_edge.origin
    end
    parent
  end
  
  def children=(children)
    @children_edges = children.map{|child| Edge.new(self, child)}
  end
  
  def parent=(parent)
    @parent_edge = Edge.new(parent, self)
  end
  
  def children
    @children_edges.map{|edge| edge.target}
  end
  
  def eql?(node)
    @item == item
  end

  def copy
    node_copy = Node.new(self.item)
    node_copy.parent_edge = Edge.new(self.parent.copy, node_copy, self.parent_edge.annotations)
    node_copy.children_edges = self.children_edges.map{|edge| Edge.new(edge.origin.copy, edge.target.copy, edge.annotations)}
    node_copy
  end
  
  def hash
    item.hash
  end

  alias == eql?
  
end