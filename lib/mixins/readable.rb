module Xplain
  
  module NodeReadable
    def load(id)
      Xplain::exploration_repository.load_node(id)      
    end
  end
  
  module WorkflowReadable
    def load(id)
      Xplain::exploration_repository.load_workflow(id)      
    end
  end

  module ResultSetReadable
    def load(id)
      Xplain::exploration_repository.load_resultset(id)      
    end
    
    def find_by_node_id(node_id)
      Xplain::exploration_repository.resultset_by_node_id(node_id)
    end
  end


end