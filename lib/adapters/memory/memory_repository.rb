class MemoryRepository
  @@nodes_hash = {}
  @@results_hash = {}
  @@workflow_hash = {}
  
  def initialize(args ={})
    
  end
  
  def save_node(node)
    @@nodes_hash[node.id] = node
  end
  
  def load_node(node_id)
    if node_id.nil? || node_id.empty?
      raise ArgumentError.new("The node id must be a non-empty string!")
    end
    @@nodes_hash[node_id]
  end
  
  def resultset_by_node_id(node_id)
    @@results_hash.values.select{|result_set| result_set.include_node?(node_id)}
  end
  
  def count_resultsets
    @@results_hash.values.size
  end
  
  def save_workflow(workflow)
    @@workflow_hash[workflow.id] = workflow
  end
  
  def load_workflow(workflow_id)
    if node_id.nil? || node_id.empty?
      raise ArgumentError.new("The workflow id must be a non-empty string!")
    end
    @@workflow_hash[workflow_id]
  end
  
  def save_resultset(resultset)
    @@results_hash[resultset.id] = resultset
  end
  
  def load_resultset(resultset_id)
    if resultset_id.nil? || resultset_id.empty?
      raise ArgumentError.new("The result set id must be a non-empty string!")
    end
    @@results_hash[resultset_id]
  end

end