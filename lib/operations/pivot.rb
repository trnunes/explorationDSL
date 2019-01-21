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
    
    @input_set = @inputs.first
    if server && @relation.respond_to?(:server)
      @relation.server = server
    end
    
    #TODO repeated code, generalize it!
    @level ||= @input_set.count_levels
    level_items = @input_set.get_level(@level)
    level_items = level_items[0..@limit] if @limit > 0
    result_set = @relation.restricted_image(level_items, group_by_domain: @group_by_domain)
    if @group_by_domain
      children_by_item = result_set.to_hash_children_node_by_item
      level_items.each do |node|
        if children_by_item.has_key? node.item
          binding.pry if @debug
          node.children = children_by_item[node.item].first.children.map{|child| child.parent_edges = []; child}.uniq{|c| c.item}
        end
      end
      binding.pry if @debug
      nodes_to_return = @input_set.get_level(2)
    else
      result_set.uniq! if result_set.contain_literals?
      nodes_to_return = result_set.nodes
    end
    nodes_to_return
  end
  
  def validate
    if !@relation
      raise MissingRelationException
    end
    true
  end  

end
