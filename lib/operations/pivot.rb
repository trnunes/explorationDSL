class Pivot < Operation
  include Xplain::RelationFactory  
  
  def initialize(inputs, args={}, &block)
    super(inputs, args, &block)
    if !block_given? && args[:relation]
      @relation = args[:relation]
    end
  end
  
  def get_relation
    @relation
  end
  
  def set_relation(new_relation)
    @relation = new_relation
  end
  
  def get_results(inputs)
    if inputs.nil? || inputs.empty? || inputs.first.empty?
      return []
    end
    
    @input_set = inputs.first.to_tree
    if server
      @relation.server = server
    end
    # binding.pry
    result_set = @relation.restricted_image(@input_set.leaves)
    result_set.uniq! if result_set.contain_literals?
    result_set.nodes
  end
  
  def validate
    if !@relation
      raise MissingRelationException
    end
    true
  end  

end