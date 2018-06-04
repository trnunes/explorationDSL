class Item
  attr_accessor :servers, :id, :text, :type
  
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
  
  def text
    if @text.to_s.empty?
      @text = Xplain::Namespace.colapse_uri(id)
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
