module Navigational
  
  def image(relation, restriction=[], offset = 0, limit = -1, crossed=false &block)
    []
  end

  def domain(relation, restriction=[], offset=0, limit=-1, crossed=false, &block)
    []
  end
  
 
  def restricted_image(args)
  end

  def restricted_domain(args)
  end
  
  ###
  ### Meta-relations handlers
  ###
  def relations_image(relation, restriction=[], offset = 0, limit = -1, crossed=false &block)
    []
  end

  def relations_domain(relation, restriction=[], offset=0, limit=-1, crossed=false, &block)
    []
  end
  
 
  def relations_restricted_image(args)
  end

  def relations_restricted_domain(args)
  end

  def has_type_image(relation, restriction=[], offset = 0, limit = -1, crossed=false &block)
    []
  end

  def has_type_domain(relation, restriction=[], offset=0, limit=-1, crossed=false, &block)
    []
  end  
 
  def has_type_restricted_image(args)
    
  end

  def has_type_restricted_domain(args)
    
  end
  
  
end