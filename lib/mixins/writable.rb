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
      self.id ||= SecureRandom.uuid
      Xplain::exploration_repository.save_resultset(self)
    end
    
    def delete()
      Xplain::exploration_repository.delete_resultset(self)
    end
        
    def self.delete_all()
      Xplain::exploration_repository.delete_all_resultsets()
    end
  end
  
  module SessionWritable
    def add_result_set(result_set)
      Xplain::exploration_repository.add_result_set(self, result_set)
    end
    
    def load_result_sets
      Xplain::exploration_repository.load_session_result_sets(self)
      return []
    end
    
    def delete
      Xplain::exploration_repository.delete_session(self)
    end
  end
end