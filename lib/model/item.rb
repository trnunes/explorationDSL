class Item
  attr_accessor :servers, :id
  
  def initialize(id)
    @id = id
    @servers = []
  end  

  def add_server(server)
    @servers << server
  end
    
  def relation?
    false
  end
  
  def type?
    false
  end
  
  def entity?
    false
  end
    
  def literal?
    false
  end
  
  def set?
    false
  end
  
  def eql?(item)
    self.class.equal?(item.class) && @id == item.id
  end
  
  def hash
    @id.hash
  end
  
  def to_s
    @id.to_s
  end
  alias == eql?
end
