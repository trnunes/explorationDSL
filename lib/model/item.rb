class Item
  include Xpair::Graph
  include Indexable
  attr_accessor :servers, :id, :text, :parents, :index, :entry, :type
  
  def initialize(id, type="")
    @id = Xpair::Namespace.expand_uri(id.gsub(" ", "%20"))
    @servers = []
    @index = Indexing::Entry.new('root')
    @entry = Indexing::Entry.new('root')
    @type = type
    @parents = []
  end
  
  
  def add_server(server)
    @servers << server
  end
  
  def clone
    cloned_item = self.class.new(@id)
    cloned_item.index = @index.copy
    cloned_item.text = self.text
    cloned_item.servers = self.servers
    cloned_item
  end
  
  def shallow_clone
    cloned_item = self.class.new(@id)
    cloned_item.text = self.text
    cloned_item
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
  
  def text
    if @text.to_s.empty?
      @text = Xpair::Namespace.colapse_uri(id)
    end
    @text
  end
  
  def eql?(item)
    if !item.respond_to? :id
      return false
    end
    @id == item.id
  end
  
  def hash
    @id.hash
  end
  
  def to_s
    @id.to_s
  end
  alias == eql?
end
