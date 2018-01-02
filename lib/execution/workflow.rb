class Workflow
  include OperationFactory
  
  attr_accessor :nodes, :server

  def initialize
    @nodes = []
  end
  
  def chain(input_operation, target_operation)
    input_node = nil
    target_node = nil
    
    if @nodes.empty?
      input_node = Node.new(input_operation)
      target_node = Node.new(target_operation)
      @nodes += [input_node, target_node]
    else
      nodes.each do |node| 
        input_node = node if node.item == input_operation
        target_node = node if node.item == target_operation
      end
    end
    # binding.pry
    if(input_node.nil?)
      input_node = Node.new(input_operation)
      @nodes << input_node
    end
    
    if(target_node.nil?)
      target_node = Node.new(target_operation)
      @nodes << target_node
    end
    
    input_node << target_node
    target_node.add_parent input_node
  end
  
  def execute()
    roots = nodes.select{|node| node.parents.empty?}
    roots.map{|root_node| execute_node(root_node)}
  end
  
  def execute_node(node)
    inputs = node.children.map{|child| execute_node(child)}
    if !inputs.empty?
      node.item.input = inputs
    end
    node.item.execute
  end
  
  def handle_operation_instance(operation_new_instance)
    @nodes << Node.new(operation_new_instance)
  end
  
  def chain_set_operation(operation_node, depedencies)
    depedencies.each{|dependent_node| chain(operation_node, dependent_node)}
  end
  
  def intersect(nodes)
    chain_set_operation(Intersect.new, nodes)
  end
  
  def union(ndoes)
    chain_set_operation(Unite.new, nodes)
  end
  
  def diff(nodes)
    chain_set_operation(Diff.new, nodes)
  end
  
end