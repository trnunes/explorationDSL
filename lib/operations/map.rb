class Map < Operation
  
  def initialize(args={}, &block)
    super(args, &block)
    if !args[:mapping_relation]
      raise MissingAuxiliaryFunctionException
    end
    @mapping_visitor = args[:mapping_relation]
    @level = args[:level]
  end
  
  def get_results
    @input_set = @input[0]
    if @input_set.nil? || @input_set.children.empty?
      return []
    end
    @level ||= @input_set.count_levels
    self.map
  end
  
  def map
    input_copy = @input_set.copy
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