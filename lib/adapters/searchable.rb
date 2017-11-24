module Searchable
  def find_relations(items)
  end
  
  def find_forward_relations(items)
  end
  
  def find_backward_relations(items)
  end
  
  def types(limit = 0, offset = 0)
    []
  end
  
  def instances(type, offset=0, limit=0)
    []
  end
  
  def relations(offset = 0, limit = 0)
    []
  end
    
  def match_all(keyword_pattern, offset = 0, limit = 0)
    []
  end  
  
  
  def all_relations(&block)
  end
  
  def each_item(&block)
  end
  
  
end