
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
      @intentino
    end
  end 
  
  
  def extension_copy
    Marshal.load(Marshal.dump(@extension))
  end
  
end