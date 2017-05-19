
class Xset
  include Explorable
  include Indexing
  include Persistable::Writable
  extend Persistable::Readable
  attr_accessor :id, :expression, :index, :relations, :server, :resulted_from, :title
  
  def initialize(id, expression)
    @id = id
    @expression = expression
    @relations = {}
    @index = Indexing::Entry.new('root')
  end
  

  
  def empty?
    @index.empty?
  end
  
end