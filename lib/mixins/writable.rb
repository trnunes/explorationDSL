require 'json'
module Xplain
  module Xplain::NodeWritable
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
      Xplain::exploration_repository.result_set_save(self)
    end
    
    def delete()
      Xplain::exploration_repository.result_set_delete(self)
    end
        
    def self.delete_all()
      Xplain::exploration_repository.result_set_delete_all()
    end
  end
  
  module SessionWritable
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    module ClassMethods
      def create(params = {})
        id = params[:id] || SecureRandom.uuid
        session = Session.new(id, params[:title])
        if Xplain.lazy?
          Xplain::memory_cache.session_save(session)  
        end
        session.save
        session
      end
    end
    
    def add_result_set(result_set)
      if result_set.id.nil?
        result_set.id = SecureRandom.uuid 
        if !Xplain.lazy?
          result_set.save
        else
          Xplain.memory_cache.result_set_save(result_set)
        end
      end
      if !Xplain.lazy?
        Xplain::exploration_repository.session_add_result_set(self, result_set)
      end
      if !@result_sets.include? result_set
        @result_sets.unshift result_set
      end
    end
    
    def remove_result_set(result_set)
      Xplain::exploration_repository.session_remove_result_set(self, result_set)
      @result_sets.delete(result_set)
    end
    
    def remove_result_set_permanently(result_set)
      remove_result_set result_set
      result_set.delete
    end
    
    def save
      if Xplain.lazy?
        @result_sets.each do |rs|
          rs.save 
          Xplain::exploration_repository.session_add_result_set(self, rs)
        end
      end
      Xplain::exploration_repository.session_save(self)
    end
    
    def delete
      Xplain.memory_cache.session_delete(self)
      Xplain::exploration_repository.session_delete(self)
    end
  end
end