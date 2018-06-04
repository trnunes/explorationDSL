module Xplain
  
  module NodeReadable
    def load(id)
      Xplain::session_repository.load_node(id)      
    end
  end
  
  module WorkflowReadable
    def load(id)
      Xplain::session_repository.load_workflow(id)      
    end
  end

  module ResultSetReadable
    def load(id)
      Xplain::session_repository.load_resultset(id)      
    end
  end


end