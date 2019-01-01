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
    
    def delete()
      Xplain::exploration_repository.delete_resultset(self)
    end
        
    def self.delete_all()
      Xplain::exploration_repository.delete_all_resultsets()
    end
  end
end