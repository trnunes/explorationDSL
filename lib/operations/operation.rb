#TODO IMPLEMENT SERVER DELEGATORS FOR OPERATIONS COVERED BY THE REPOSITORY. IF THE OPERATION IS AVAILABLE, IT MUST BE DELEGATED TO  THE REPOSITORY.
class Operation
  include OperationFactory
  attr_accessor :input, :server, :id
  def initialize(args={}, &block)
    @id = args[:id] || SecureRandom.uuid
    setup_input args[:input]
    @server = args[:server] || Xplain.default_server
    @definition_block = block if block_given?
  end
  
  def setup_input(operation_input)
    #test if the input is a simple array of items and transform it to a tree
    if operation_input.respond_to?(:each) && !operation_input.respond_to?(:leaves) && !self.accept_multiple_sets?
      root = Node.new(Xplain::Entity.new(SecureRandom.uuid))
      root.children = operation_input.map do |input_item|
        if !input_item.is_a? Node
          input_item = Node.new(input_item)
        end
        input_item
      end
      @input = root
    else
      @input = operation_input
    end
  end
  
  def accept_multiple_sets?
    return false
  end
  
  def input=(operation_input)
    setup_input operation_input
  end
  
  def execute()
    if @definition_block
      self.instance_eval &@definition_block
    end
    validate
    root = Node.new(Xplain::Entity.new(SecureRandom.uuid))
    root.intention = self
    root.children = get_results()
    root
  end
  
  def validate
    if input.nil?  || !(input.respond_to?(:each) || input.is_a?(Node))
      raise InvalidInputException
    end
    true
  end
  
  def get_results
    []
  end
  
  def handle_auxiliary_function(klass, *args, &block)
    @auxiliar_function = klass.new(*args, &block)
  end
  
  def handle_operation_instance(operation_new_instance)
    Xplain.get_current_workflow.chain(operation_new_instance, self)
  end
  
  def eql?(operation)
    operation.is_a?(self.class) && @id == operation.id
  end

  def hash
    @id.hash
  end

  alias == eql?
  
end