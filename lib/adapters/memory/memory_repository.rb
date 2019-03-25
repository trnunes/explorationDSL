class MemoryRepository
  @@nodes_hash = {}
  @@results_hash = {}
  @@workflow_hash = {}
  @@session_hash = {}
  
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
  
  def result_set_find_by_node_id(node_id)
    @@results_hash.values.select{|result_set| result_set.include_node?(node_id)}
  end
  
  def result_set_count
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
  
  def result_set_save(resultset)    
    
    setup_ids resultset
    @@results_hash[resultset.id] = resultset
  end
  
  def setup_ids(node)
    node.id ||= SecureRandom.uuid
    node.children.each{|c| setup_ids c}
  end
  
  def result_set_load(resultset_id)
    if resultset_id.nil? || resultset_id.empty?
      raise ArgumentError.new("The result set id must be a non-empty string!")
    end
    @@results_hash[resultset_id]
  end
  
  def session_save(session)
   @@session_hash[session.id] = session 
  end
  
  def session_find_by_title(title)
    @@session_hash.values.select{|s| s.title == title}
  end
  
  def session_load(id)
    @@session_hash[id]
  end
  
  def session_delete(session)
    @@session_hash.delete(session.id)
  end
  
  def sessions
    @@session_hash
  end


end