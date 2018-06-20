#TODO IMPLEMENT SERVER DELEGATORS FOR OPERATIONS COVERED BY THE REPOSITORY. IF THE OPERATION IS AVAILABLE, IT MUST BE DELEGATED TO  THE REPOSITORY.

class Operation
  
  include Xplain::GraphConverter
  ### Flag to inform whether the operation receives multiple sets as input or not.
  MULTI_SET = false
  
  attr_accessor :params, :server, :inputs, :id   
  
  def initialize(inputs=nil, args={}, &block)
    # binding.pry
    @id = args[:id] || SecureRandom.uuid
    setup_input inputs
    @server = args[:server] || Xplain.default_server
    @definition_block = block if block_given?
  end

  def self.operation_class?(klass)
    operation_subclasses = ObjectSpace.each_object(Class).select {|space_klass| space_klass < Operation }
    operation_subclasses.include? klass
  end
  
  def setup_input(inputs)
    #test if the input is a simple array of items and transform into a tree
    if inputs.is_a?(Xplain::ResultSet) || inputs.is_a?(Operation)
      @inputs = [inputs]
    else
      @inputs = inputs
    end
    
  end
  
  def self.accept_multiple_sets?
    return self::MULTI_SET
  end
  
  def to_expression
    self.class.to_s.downcase
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
    Xplain::ResultSet.new(SecureRandom.uuid, get_results(get_inputs()), self)        
  end
  
  def get_inputs
    if @inputs
      @inputs = @inputs.map do |input|
        if input.is_a? Operation
          input.execute()
        else
          input
        end
      end  
    end
    @inputs
  end
  
  def validate
    true
  end
  
  def get_results
    []
  end

  def method_missing(m, *args, &block)

    instance = nil
    # binding.pry
    klass = Object.const_get m.to_s.to_camel_case
    

    if !Operation.operation_class? klass
      if !auxiliary_function? klass
        raise NameError.new("Auxiliary function #{klass.to_s} does not exist!")
      end      
      return handle_auxiliary_function(klass, *args, &block)
    end
    
    
# binding.pry
    if args.nil?
      args = [[]]
    end
    
    if (!args.first.is_a? Array)
      if args.first.nil?
        args << []
      else
        args[0] = [args[0]]
      end
          
    end
    args[0] << self
    
    target_promisse = klass.new(*args, &block)
        
    return target_promisse
  end  
  
  
  def auxiliary_function?(function_klass)
    auxiliary_function_subclasses = ObjectSpace.each_object(Class).select {|space_klass| space_klass < AuxiliaryFunction}
    auxiliary_function_subclasses.include? function_klass    
  end
   
  def handle_auxiliary_function(klass, *args, &block)
    @auxiliar_function = klass.new(*args, &block)
  end
  
  def eql?(operation)
    operation.is_a?(self.class) && @id == operation.id
  end

  def hash
    @id.hash
  end

  alias == eql?
  
end

class String
  
  def to_underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
  
  def to_camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end