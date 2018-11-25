class Xplain::NodesSelect < Xplain::Operation
  def initialize(args={}, &block)    
    super(args, &block)
    @ids_list = args[:ids]
  end
  
  
  def get_results()
    result_nodes = []
    if !@inputs || @inputs.empty?
      return []
    end
    
    @inputs.each do |input_set|
      @ids_list.each do |item_id|
        result_nodes += self.by_item_id(input_set, item_id)
      end
    end
    result_nodes
  end
  
  def by_node_id(result_set, node_id)
    result_set.breadth_first_search(false){|node| node.id == node_id}
  end
  
  def by_item_id(result_set, item_id)
    result_set.breadth_first_search do |node| 
        comparison_value =
          if node.item.is_a? Xplain::Literal
            node.item.value
          else
            node.item.id
          end
        comparison_value == item_id
    end
  end
end