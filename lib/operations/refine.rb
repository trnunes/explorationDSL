class Refine < Operation
  include Xplain::FilterFactory
  attr_accessor :auxiliary_function
  def initalize(inputs, args = {}, &block)
    super(inputs, args, &block)
    if !@auxiliary_function && args[:filter]
      @auxiliary_function = args[:filter]
    end
  end
  
  def get_results(inputs)
    
    if inputs.nil? || inputs.empty? || inputs.first.empty?
      return []
    end

    input_set = inputs.first.to_tree
    if(input_set.children.empty?)
      return []
    end

    nodes_to_filter = input_set.leaves
    
    non_interpretable_filters = @server.validate_filters(@auxiliar_function)

    #TODO the memory intepreter should navigate the tree respecting the order and position
    if !non_interpretable_filters.empty?
      interpreter = InMemoryFilterInterpreter.new(non_interpretable_filters, nodes_to_filter)
      nodes_to_filter = @auxiliar_function.accept(interpreter)
    end

    if @server.can_filter? @auxiliar_function
      nodes_to_filter = to_nodes(@server.filter(nodes_to_filter.map{|node| node.item}, @auxiliar_function))
    end
    nodes_to_filter
  end
end