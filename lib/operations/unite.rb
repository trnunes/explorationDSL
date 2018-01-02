class Unite < SetOperation
  
  def compute(input, target)
    parent = Node.new('unite')
    first_level = input.children + target.children
    
    if !first_level.is_a?(Xplain::Literal)
      first_level = Set.new(first_level)
    end
    
    parent.children = first_level
    first_level.each{|node| node.parent = parent}
    
    input.children.each do |child1|
      target.children.each do |child2|
        if(child1 == child2)
          node_unite(child1, child2, parent)
        end
      end
    end

    return parent.children
  end
  
  def node_unite(n1, n2, parent)
    parent << n1
    n1.parent = parent
    # binding.pry
    if(n1 == n2)
      n1.children.each do |child_n1|      
        n2.children.each do |child_n2|
          if child_n1 == child_n2
            node_unite(child_n1, child_n2, n1)
          end
        end
      end
      union_children = n1.children + n2.children
      if !n1.children[0].is_a?(Xplain::Literal)
        n1.children = Set.new(union_children)
      else
        n1.children = union_children
      end
      
    else
      parent << n2
      n2.parent = parent 
    end
  end
end