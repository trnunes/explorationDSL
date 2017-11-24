module Navigational
  
  def image(relation, restriction=[], offset = 0, limit = -1, crossed=false &block)
    []
  end

  def domain(relation, restriction=[], offset=0, limit=-1, crossed=false, &block)
    []
  end
  
  def accept_path_clause?
    false
  end   
  
  def restricted_image(args)
  end

  def restricted_domain(args)
  end
  
end