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
   #TODO Document options
    def find_by_session(session, options = {})
      Xplain::exploration_repository.find_result_sets_by_session(session, options)
    end
    
    def count
      Xplain::exploration_repository.count_resultsets
    end
    
    def load_all
      Xplain::exploration_repository.load_all_resultsets
    end
    
    def load_all_tsorted()
      result_sets = Xplain::exploration_repository.load_all_resultsets
      topological_sort(result_sets)
    end
    
    #TODO duplicated code with load_all_tsorted
    def load_all_tsorted_exploration_only
      result_sets = Xplain::exploration_repository.load_all_resultsets(exploration_only: true)
      topological_sort(result_sets)
    end
    
    def load_all_exploration_only
      Xplain::exploration_repository.load_all_resultsets(exploration_only: true)
    end
    
    #private
    def topological_sort(result_sets)
      sorted_array = []
      visited = Set.new
      result_sets.each{|rs| visit(rs, sorted_array, visited)}
      sorted_array
    end
    

    def visit(rs, sorted_array, visited)
      #TODO change the intention setup to always be an Operation
      if rs.intention && rs.intention.is_a?(Operation)
        rs.intention.inputs.each{|input| visit(input, sorted_array, visited)}
      end
      if !visited.include? rs.id
        sorted_array << rs
        visited << rs.id
      end
    end
  end
  
  module SessionReadable
    def find_by_title(title)
      Xplain::exploration_repository.find_session_by_title(title)
    end
    
    def list_titles
      Xplain::exploration_repository.list_session_titles
    end
  end


end