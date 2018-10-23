class Xmap < Operation
  
  def initialize(inputs, args={}, &block)
    super(inputs, args, &block)
    if args[:mapping_relation]
      @auxiliar_function = args[:mapping_relation]
    end
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
    if @auxiliar_function.respond_to? :prepare
      @auxiliar_function.prepare(nodes_to_map)
    end
    nodes_to_map.each do |node|
      results = node.accept(@auxiliar_function)
      node.children = results
    end
    
    input_copy.children
  end
end