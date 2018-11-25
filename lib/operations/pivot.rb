class Xplain::Pivot < Xplain::Operation
  include Xplain::RelationFactory  
  
  def initialize(args={}, &block)
    super(args, &block)
    if !block_given? && args[:relation]
      @relation = args[:relation]
    end

    @group_by_domain = args[:group_by_domain] || false
  end
  
  def get_relation
    @relation
  end
  
  def set_relation(new_relation)
    @relation = new_relation
  end
  
  def get_results()
    if @inputs.nil? || @inputs.empty? || @inputs.first.empty?
      return []
    end
    
    @input_set = @inputs.first.to_tree
    if server && @relation.respond_to?(:server)
      @relation.server = server
    end
    
    #TODO repeated code, generalize it!
    @level ||= @input_set.count_levels
    level_items = @input_set.get_level(@level)
    level_items = level_items[0..@limit] if @limit > 0
    result_set = @relation.restricted_image(level_items, group_by_domain: @group_by_domain)
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
