class Group < Operation
  
  def initialize(inputs, args={}, &block)
    super(inputs, args, &block)
    if args[:grouping_relation]
      @auxiliar_function = args[:grouping_relation]
      @level = args[:level]
    end
  end
  
  def get_results(inputs)
    if inputs.nil? || inputs.empty? || inputs.first.empty?
      return []
    end

    input_set = inputs.first
    
    if input_set.nil? || input_set.to_tree.children.empty?
      return []
    end
    
    input_copy = input_set.to_tree.copy
    
    @level ||= input_copy.count_levels - 1

    next_to_last_level = input_copy.get_level(@level)
    nodes_to_group = []
    next_to_last_level.each do |node|
      nodes_to_group += node.children
    end
    new_groups = []
    @auxiliar_function.prepare(nodes_to_group, new_groups)
    new_groups = @auxiliar_function.group(nodes_to_group)
    
    next_to_last_level.each do |node|
      children = node.children
      node.children_edges = []
      new_groups.each do |grouping_node|
        new_grouping_node = Node.new(grouping_node.item)
        
        node.children_edges << Edge.new(node, new_grouping_node)
        
        relation_node = grouping_node.children.first
        new_relation_node = Node.new(relation_node.item)
        new_grouping_node.children_edges = [Edge.new(new_grouping_node, new_relation_node)]
        relation_children_items = Set.new(relation_node.children.map{|node| node.item})
        new_relation_node.children_edges = children.select{|node| relation_children_items.include?(node.item)}.map do |child| 
          Edge.new(new_relation_node, child)
        end
      end
    end
    # binding.pry
    input_copy.get_level(2)
  end
  
end