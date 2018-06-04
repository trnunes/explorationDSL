class SetOperation < Operation
  
  ###Informing that the instances of this class receive multiple sets as inputs
  MULTI_SET = true
  
  def get_results()
    parent = Node.new('unite')
    
    input = @input[0]
    target = @input[1]
    
    if(input.nil? || input.to_tree.children.empty?)
      if(target)
        return target.to_tree.copy.children
      end
    else
      if(target.nil? || target.to_tree.children.empty?)
        return input.to_tree.copy.children
      end
    end
    
    input = input.to_tree.copy
    target = target.to_tree.copy
    compute(input, target)
  end
  
  def validate
    if @input.nil?
      raise InvalidInputException.new("Nil input for Unite operation!")
    end
  
  end
  
  def accept_multiple_sets?
    return true
  end
    
end