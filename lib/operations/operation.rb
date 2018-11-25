#TODO IMPLEMENT SERVER DELEGATORS FOR OPERATIONS COVERED BY THE REPOSITORY. IF THE OPERATION IS AVAILABLE, IT MUST BE DELEGATED TO  THE REPOSITORY.

class Xplain::Operation
  
  include Xplain::GraphConverter
  
  attr_accessor :params, :server, :inputs, :id   
  @base_dir = ""
  class << self
    attr_accessor :base_dir, :function_module
  end
  
  def initialize(args={}, &block)
    if !args.is_a? Hash
      args = {inputs: args}
    end
    @id = args[:id] || SecureRandom.uuid
    setup_input args
    @server = args[:server] || Xplain.default_server
    @definition_block = block if block_given?
    @level = args[:level]
    @limit = args[:limit] || 0
    
  end

  def self.operation_class?(klass)
    operation_subclasses = ObjectSpace.each_object(Class).select {|space_klass| space_klass < Xplain::Operation }
    operation_subclasses.include? klass
  end
  
  def setup_input(args)
    inputs = args[:inputs]
    is_result_set_or_operation = inputs.is_a?(Xplain::ResultSet) || inputs.is_a?(Xplain::Operation)
    is_array_of_nodes =  inputs.is_a?(Array) && (inputs.map{|input| input.class}.uniq == [Node])
    if is_result_set_or_operation || is_array_of_nodes 
      @inputs = [inputs]
    else 
      @inputs = inputs
    end
    @inputs ||= []
  end
  
  #TODO implement this operation to express the operation and its parameters  
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
    resolve_dependencies()
    result_nodes = get_results()
    result_nodes.each{|node| node.parent_edges = []}
    Xplain::ResultSet.new(SecureRandom.uuid, result_nodes, self)        
  end
  
  def resolve_dependencies
    @inputs = @inputs.map do |input|
      if input.is_a? Xplain::Operation
        input.execute().copy
      else
        input.copy
      end
    end  
  end
  
  def validate
    true
  end
  
  def get_results
    []
  end

  def method_missing(m, *args, &block)

    instance = nil

    begin
      require Xplain.base_dir + "operations/" + m.to_s.to_underscore + ".rb"

      klass = Object.const_get "Xplain::" + m.to_s.to_camel_case
    rescue LoadError

      if self.class.function_module

        Dir[Xplain.base_dir + "operations/" + self.class.function_module.to_s.to_underscore + "/*.rb"].each {|file| require file }

        begin
        klass = Object.const_get self.class.function_module.to_camel_case + "::" + m.to_s.to_camel_case
        rescue LoadError
          raise "operation/auxiliary function not available!"
        end
      end
    end

    if !Xplain::Operation.operation_class? klass
      if !auxiliary_function? klass
        raise NameError.new("Auxiliary function #{klass.to_s} does not exist!")
      end      
      return handle_auxiliary_function(klass, *args, &block)
    end
    
    

    if args.nil? || args.empty?
      args = {}
    elsif args[0].is_a? Hash 
       args = args[0]
    else
      args = {:inputs => args}
    end
     
    if !args[:inputs]
      args[:inputs] = []
    elsif !args[:inputs].is_a? Array
      args[:inputs] = [args[:inputs]]
    end
    
    args[:inputs] << self    
    target_promisse = klass.new(args, &block)
        
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