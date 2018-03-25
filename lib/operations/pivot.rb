class Pivot < Operation
  include Xplain::RelationFactory
  
  def initialize(args={}, &block)
    super(args, &block)
    if !block_given? && args[:relation]
      @relation = args[:relation]
    end
  end
  
  def get_relation
    @relation
  end
  
  def get_results()
    @input_set = @input
    if server
      @relation.server = server
    end
    result_set = @relation.restricted_image(@input_set.leaves)
    result_set.uniq! if result_set.contain_literals?
    result_set
  end
  
  def validate
    if !@relation
      raise MissingRelationException
    end
    true
  end  

end
