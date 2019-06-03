module Xplain
  
  module Xplain::NodeReadable
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
    def load_intention(id)
      rs = load(id)
      rs.intention if rs
    end
    
    def load(id)
      result_set = Xplain::memory_cache.result_set_load(id)
      if !result_set
        result_set = Xplain::exploration_repository.result_set_load(id)
        if Xplain.cache_results?
          Xplain::memory_cache.result_set_save(result_set)
        end 
      end
      result_set
    end
    
    def find_by_node_id(node_id)
      result_sets = Xplain::memory_cache.result_set_find_by_node_id(node_id)
      
      if result_sets.empty?
        result_sets = Xplain::exploration_repository.result_set_find_by_node_id(node_id) 
      end
      result_sets
    end
   #TODO Document options
    def find_by_session(session, options = {})
      sets = Xplain::exploration_repository.result_set_find_by_session(session, options)
      sets.map{|set| Xplain::memory_cache.result_set_load(set.id) || Xplain::memory_cache.result_set_save(set)}
      
    end
    
    def count
      Xplain::exploration_repository.result_set_count
    end
    
    def load_all
      Xplain::exploration_repository.result_set_load_all
    end
    
    def load_all_tsorted
      Xplain::ResultSet.topological_sort Xplain::exploration_repository.result_set_load_all
    end
    
    def load_all_exploration_only
      Xplain::exploration_repository.result_set_load_all(exploration_only: true)
    end
    
    def load_all_tsorted_exploration_only
      all_rs = Xplain::exploration_repository.result_set_load_all(exploration_only: true)
      Xplain::ResultSet.topological_sort all_rs 
    end
    

  end
  
  module SessionReadable
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    #TODO refactor other readables and writables such this one
    module ClassMethods
      def load(id)
        session = Xplain::memory_cache.session_load(id)
        if !session
          session = Xplain::exploration_repository.session_load(id)
          Xplain::memory_cache.session_save(session)
        end
        session
      end
      
      def find_by_title(title)
        sessions = Xplain::exploration_repository.session_find_by_title(title)
        sessions.each{|s| Xplain::memory_cache.session_save(s)}
        sessions
      end
      
      def list_titles
        Xplain::exploration_repository.session_list_titles
      end
    end

  end


end