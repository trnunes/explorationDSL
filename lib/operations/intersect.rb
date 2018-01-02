class Intersect < SetOperation

  def compute(input, target)
    parent = Node.new('intersect')
    node_intersect(input, target, parent)
    return parent.children
  end
  
  def node_intersect(n1, n2, parent)
    n1.children.each do |child_n1|
      n2.children.each do |child_n2|
        if child_n1 == child_n2
          new_child = Node.new(child_n1.item)
          parent << new_child
          node_intersect(child_n1, child_n2, new_child)
        end
      end
    end
  end
  
end