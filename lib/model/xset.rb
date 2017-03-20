
class Xset
  include Xenumerable
  include HashExplorable
  include Persistable::Writable
  extend Persistable::Readable
  attr_accessor :server, :extension, :intention, :resulted_from, :generates, :id, :projection, :relation_index, :subset_of

  def initialize(&block)
    @bindings = {}
    @extension = {}      
    @generates = []
    @relation_index = {}
    @subset_of = nil
    yield(self) if block_given?
    self
  end
  
  def projection
    if @projection.nil?

      domain_items()
    end
    @projection
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
  
  def order_relations(relations)

    ordered_relations = []
    
    relations_hash = relations.map{|r| [r.resulted_from, r]}.to_h
    result_set = relations_hash[self]
    ordered_relations << result_set
    while(result_set != nil && ordered_relations.size < relations.size)
      result_set = relations_hash[result_set]
      ordered_relations << result_set
    end
    ordered_relations
  end
  
  def extension=(hash)
    @extension = hash
    # Xpair::Graph.generate_graph(@extension)

  end  
end