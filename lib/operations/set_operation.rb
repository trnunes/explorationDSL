class Xplain::SetOperation < Xplain::Operation
  
  ###Informing that the instances of this class receive multiple sets as inputs
  MULTI_SET = true
  
  def get_results()
    parent = Xplain::Node.new()
    
    input = @inputs[0]
    target = @inputs[1]
    if !(input || target)
      return []
    end
    
    if(input.nil? || input.children.empty?)
      if(target)
        return target.children
      end
    else
      if(target.nil? || target.children.empty?)
        return input.children
      end
    end
    
    compute(input, target)
  end
  
  def validate()
    if @inputs.nil?
      raise InvalidInputException.new("Nil input for operation!")
    end
  
  end
  #TODO Remove. This method is no longer needed.
  def accept_multiple_sets?
    return true
  end
    
end