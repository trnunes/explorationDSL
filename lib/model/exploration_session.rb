class ExplorationSession
  include Persistable::Writable
  extend Persistable::Readable
  
  attr_accessor :description, :id
  
  def initialize(session_id)
    @id = session_id
    @sets = []
  end
  
  def add_set(xset)
    @sets << xset
  end
  
  def position_of(xset)
    @sets.index(xset) + 1
  end
  
end