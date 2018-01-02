class Refine < Operation
  include Xplain::FilterFactory
  def initalize(args = {}, &block)
    super(args, &block)
    if !@auxiliary_function && args[:filter]
      @auxiliary_function = args[:filter]
    end
  end
  
  def get_results()
    @input_set = @input[0]
    if(@input_set.children.empty?)
      return []
    end
    @server.filter(@input_set.leaves, @auxiliar_function)
  end
  
end