class NodesSelect < Operation
  def initialize(inputs, ids_list , &block)    
    super(inputs, {}, &block)
    @ids_list = ids_list
  end
  
  
  def get_results(input_set_list)
    result_nodes = []
    input_set_list.each do |input_set|
      @ids_list.each do |item_id|
        result_nodes += input_set.search_first(item_id)
      end
    end
    result_nodes
  end
  
end