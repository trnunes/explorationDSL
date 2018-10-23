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

    input_nodes = input_set.leaves
    
    non_interpretable_filters = @server.validate_filters(@auxiliar_function)
    if !non_interpretable_filters.empty?
      interpreter = InMemoryFilterInterpreter.new(non_interpretable_filters, input_nodes)
      input_nodes = @auxiliar_function.accept(interpreter)
    end

    if @server.can_filter? @auxiliar_function
      input_nodes = to_nodes(@server.filter(input_nodes.map{|node| node.item}, @auxiliar_function))
    end
    
    input_nodes
  end
end