
class Xset
  include Xenumerable
  include HashExplorable
  include Persistable::Writable
  extend Persistable::Readable
  attr_accessor :server, :extension, :intention, :resulted_from, :generates, :id

  def initialize(&block)
    @bindings = {}
    @extension = {}      
    @generates = []

    yield(self) if block_given?
    self
  end
  
  def bindings(&block)    
    yield(@bindings)
  end
  
  def intention
    if root?
      "Xset.load(\"#{id}\")"
    else
      @intention
    end
  end
  
  def view_expression
    $CURRENT_SESSION
  end
  
  def resuled_from=(resulted_set)
    @resulted_from = resulted_set
    resulted_set.generates << self
  end
  
  def generates=(generated_set)
    @generates << generated_set
    generated_set.resulted_from = self
  end
  
  
  def extension_copy
    Marshal.load(Marshal.dump(@extension))
  end
  
end