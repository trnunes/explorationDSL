class Refine < Operation
  include Xplain::FilterFactory
  def initalize(args = {}, &block)
    super(args, &block)
    if !@auxiliary_function && args[:filter]
      @auxiliary_function = args[:filter]
    end
  end
  
  def get_results()
    input_set = @input
    nodes_to_filter = @input.leaves
    if(input_set.children.empty?)
      return []
    end
    non_interpretable_filters = @server.validate_filters(@auxiliar_function)
    if !non_interpretable_filters.empty?
      interpreter = InMemoryFilterInterpreter.new(non_interpretable_filters, nodes_to_filter)
      nodes_to_filter = @auxiliar_function.accept(interpreter)
    end

    if @server.can_filter? @auxiliar_function
      nodes_to_filter = @server.filter(nodes_to_filter, @auxiliar_function)
    end
    nodes_to_filter
  end
end