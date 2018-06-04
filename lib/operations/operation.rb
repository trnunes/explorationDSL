#TODO IMPLEMENT SERVER DELEGATORS FOR OPERATIONS COVERED BY THE REPOSITORY. IF THE OPERATION IS AVAILABLE, IT MUST BE DELEGATED TO  THE REPOSITORY.
class Operation
  include OperationFactory
  include Xplain::GraphConverter
  ### Flag to inform whether the operation receives multiple sets as input or not.
  MULTI_SET = false
  
  attr_accessor :input, :server, :id  
  
  def initialize(args={}, &block)
    @id = args[:id] || SecureRandom.uuid
    setup_input args[:input]
    @server = args[:server] || Xplain.default_server
    @definition_block = block if block_given?
  end
  
  def setup_input(operation_input)
    #test if the input is a simple array of items and transform into a tree
    @input = operation_input
    if operation_input.respond_to?(:each) && !operation_input.is_a?(Xplain::ResultSet) 
      if !self.class::accept_multiple_sets?
        @input = operation_input.first
      end
    end    
  end
  
  def self.accept_multiple_sets?
    return self::MULTI_SET
  end
  
  def input=(operation_input)
    setup_input operation_input
  end
  
  def execute()
    if @definition_block
      self.instance_eval &@definition_block
    end
    validate()
    # binding.pry
    Xplain::ResultSet.new(SecureRandom.uuid, get_results(), self)        
  end
  
  def validate
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