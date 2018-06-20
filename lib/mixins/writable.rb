require 'json'
module Xplain
  module NodeWritable
    def save()
      Xplain::exploration_repository.save_node(self)
    end
  end
  
  module WorkflowWritable
    def save()
      Xplain::exploration_repository.save_workflow(self)
    end
  end
  
  module ResultSetWritable
    def save()
      Xplain::exploration_repository.save_resultset(self)
    end
  end
end