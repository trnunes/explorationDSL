class Node
  attr_accessor :id, :item, :parent_edges, :children_edges, :annotations
  
  def initialize(item = nil, id = nil, annotations = [])
    @children_edges = []
    @annotations = annotations
    if item.is_a? Node
      raise InvalidArgumentError("The item cannot be a Node!");
    end
    @item = item
    @id = id || "node:" + SecureRandom.uuid
    @parent_edges = []
  end
  
  def result_set
    
    parent = self
    while (!parent.parent.nil?)
      parent = parent.parent
    end
    return parent    
  end
  
  
  def annotate(annotation)
    @annotations << annotation
  end
  
  def parents
    Set.new(@parent_edges.map{|edge| edge.origin})
  end
  
  def parent
    parent = nil
    if(@parent_edges[0])
      parent = @parent_edges[0].origin
    end
    parent
  end
  
  def same_branch(node)
    self.ancestors.shift == node.ancestors.shift
  end
  
  def remove_child(child)
    @children_edges.delete_if{|edge| edge.target == child}
  end
  
  def ancestors
    ancestors_list = []
    ancestor = parent
    while(ancestor) do
      ancestors_list << ancestor
      ancestor = ancestor.parent
    end
    ancestors_list
  end
  
  def accept(visitor)
    visitor.visit(self)
  end
  
  def add_parent(parent)
    @parent_edges << Edge.new(parent, self)
  end
  
  def children=(children_set)
    if children_set
      @children_edges = children_set.map do |child| 
        child.add_parent self
        Edge.new(self, child)
      end 
    end
  end
  
  def append_children(children_set)
    @children_edges += children_set.map do |child| 
      child.add_parent self
      Edge.new(self, child)
    end
  end
  
  def parent_edge=(parent_edge)
    @parent_edges << parent_edge
  end
  
  def parent=(parent)
    @parent_edges = []
    add_parent parent
  end
  
  def children
    @children_edges.map{|edge| edge.target}
  end
  
  def get_level_relation(level)
    Xplain::ComputedRelation.new(domain: get_level(level))
  end
  
  def leaf?
    children.empty?
  end
  
  def copy
    node_copy = Node.new(self.item)

    node_copy.children_edges = self.children_edges.map{|edge| Edge.new(node_copy, edge.target.copy, edge.annotations)}
    node_copy.children.each{|child| child.parent_edge = Edge.new(node_copy, child)}
    node_copy
  end
  
  def each_level(&block)
    levels = []

    current_level = [self]

    while !current_level.empty?
      levels << current_level
      if block_given?
        yield(current_level)
      end
      current_level = current_level.map{|li| li.children}.flatten

    end
    levels
  end

  def count_levels
    number_of_levels = 0
    each_level{number_of_levels+=1}
    number_of_levels
  end

  def get_level(level, parents_restriction=[], children_restriction= [], offset=0, limit=-1)
    level_items = []
    current_level = 0
    each_level{|current_level_items| level_items = current_level_items if ((current_level += 1) == level)}
    if(limit > 0 && offset >= 0 )
      level_items = level_items[offset..(offset+limit)-1]
    end
    level_items
  end
  
  def find(item_to_find)
    if self.item == item_to_find
      return self
    end
    each_level do |level_nodes| 
      selected_nodes = level_nodes.select{|node| node.item == item_to_find}
      if !selected_nodes.empty?
        return selected_nodes.first
      end
    end
    return nil
  end
  
  def leaves
    each_level.last
  end
  
  def eql?(node)
    node.id == @id
  end
  
  def <<(child)
    @children_edges << Edge.new(self, child)
  end
  
  def hash
    @id.hash
  end
  
  def to_s
    
    "N " + @item.to_s
  end
  
  def to_hash_children_node_by_item
    hash_children_node_by_item = {} 
    children.each do |child|
      
      if !hash_children_node_by_item.has_key? child.item
        hash_children_node_by_item[child.item] = []
      end
      hash_children_node_by_item[child.item] << child
    end
    hash_children_node_by_item
    
  end
  
  def children_items
    children.map{|node| node.item}    
  end
  
  def inspect
    inspect_string = ""
    
    inspect_string << self.to_s + "\n   => ["+ @children_edges.map{|c| c.to_s }.join(", ") + "]"
    inspect_string
  end
  
  alias == eql?
  
end