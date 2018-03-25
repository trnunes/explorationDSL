class Query < Operation
  include Xplain::FilterFactory
  def initalize(args = {}, &block)
    super(args, &block)
    if !@auxiliary_function && args[:filter]
      @auxiliary_function = args[:filter]
    end
  end
  
  def validate()
    return true
  end
  
  def get_results()
    input_nodes = []
    if @input
      input_nodes = @input.leaves
    end
    @server.dataset_filter(input_nodes, @auxiliar_function)
  end
  
end

class FindRelations
end