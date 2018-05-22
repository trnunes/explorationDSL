module GroupingExpression
  
  class RestrictedImage
    
    def initialize(relation)
      @relation = relation
    end
    
    def execute(item)
      item.server.begin
    end
    
  end

  def initialize(xset)
  end
  
  def image(relation)
  end
  
  def expression
  end
end