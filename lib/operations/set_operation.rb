class SetOperation < Operation
  def get_results()
    parent = Node.new('unite')
    
    input = @input[0]
    target = @input[1]
    
    if(input.nil? || input.children.empty?)
      if(target)
        return target.copy.children
      end
    else
      if(target.nil? || target.children.empty?)
        return input.copy.children
      end
    end
    
    input = input.copy
    target = target.copy
    compute(input, target)
  end
  
  def accept_multiple_sets?
    return true
  end
    
end