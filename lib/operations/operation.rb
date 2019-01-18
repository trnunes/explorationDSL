#TODO IMPLEMENT SERVER DELEGATORS FOR OPERATIONS COVERED BY THE REPOSITORY. IF THE OPERATION IS AVAILABLE, IT MUST BE DELEGATED TO  THE REPOSITORY.

class Xplain::Operation
  
  include Xplain::GraphConverter
  include Xplain::DslCallable
  
  attr_accessor :params, :server, :inputs, :id, :auxiliar_function, :definition_block, :args
  @base_dir = ""
  class << self
    attr_accessor :base_dir, :function_module
  end
  
  def initialize(args={}, &block)
    if !args.is_a? Hash
      args = {inputs: args}
    end
    @args = args
    @id = args[:id] || SecureRandom.uuid
    setup_input args
    @server = args[:server] || Xplain.default_server
    @level = args[:level]
    @limit = args[:limit] || 0
    @debug = args[:debug] || false
    @relation = args[:relation]
    @visual = args[:visual] || false
    if block_given?
      @definition_block = block 
      self.instance_eval &@definition_block
    end
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
  
  def summarize
    self.class.to_s.downcase.gsub("xplain::", "")
  end
  
  def input=(operation_input)
    setup_input operation_input
  end
  
  def execute()
    validate()
    resolve_dependencies()
    result_nodes = get_results()
    result_nodes.each{|node| node.parent_edges = []}
    Xplain::ResultSet.new(nil, result_nodes, self)        
  end
  
  def resolve_dependencies
    @inputs = @inputs.map do |input|
      if input.is_a? Xplain::Operation
        rs = input.execute()
        rs.save
        rs.copy
      else
        if input.id.nil?
          input.save
        end
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

  def handle_auxiliary_function(klass, *args, &block)

    @auxiliar_function = super
  end
  
  def eql?(operation)
    operation.is_a?(self.class) && @id == operation.id
  end

  def hash
    @id.hash
  end

  alias == eql?
  
end
