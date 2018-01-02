#TODO IMPLEMENT SERVER DELEGATORS FOR OPERATIONS COVERED BY THE REPOSITORY. IF THE OPERATION IS AVAILABLE, IT MUST BE DELEGATED TO  THE REPOSITORY.
class Operation
  include OperationFactory
  attr_accessor :input, :server, :id
  def initialize(args={}, &block)
    @id = args[:id] || SecureRandom.uuid
    @input = args[:input]
    @input = [@input] if !@input.respond_to?(:each)
    @server = args[:server]
    @definition_block = block if block_given?
  end
  
  def execute()
    if @definition_block
      self.instance_eval &@definition_block
    end
    validate
    root = Node.new(Xplain::Entity.new(SecureRandom.uuid))
    root.children = get_results()
    root
  end
  
  def validate
    if input.nil?  || !(input.respond_to?(:each) && input[0].is_a?(Node))
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