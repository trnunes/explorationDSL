class Map < Operation
  
  def initialize(inputs, args={}, &block)
    super(inputs, args, &block)
    if !args[:mapping_relation]
      raise MissingAuxiliaryFunctionException
    end
    @mapping_visitor = args[:mapping_relation]
    @level = args[:level]
  end
  
  def get_results(inputs)
    if inputs.nil? || inputs.empty? || inputs.first.empty?
      return []
    end

    @input_set = inputs.first
    if @input_set.nil? || @input_set.to_tree.children.empty?
      return []
    end
   
    @level ||= @input_set.to_tree.count_levels
    self.map
  end
  
  def map
    input_copy = @input_set.to_tree.copy
    nodes_to_map = input_copy.get_level(@level)
    if @mapping_visitor.respond_to? :prepare
      @mapping_visitor.prepare(nodes_to_map)
    end
    nodes_to_map.each do |node|
      results = node.accept(@mapping_visitor)
      node.children = results
    end
    input_copy.children
  end
end