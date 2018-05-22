module Xpair
  class Session
    include Persistable::Writable
    extend Persistable::Readable
    
    attr_accessor :current_index, :id, :session_name, :session_description, :sets
    
    def initialize(session_name = 'default', session_description = 'Default Session', server = nil)
      @sets = Set.new
      @current_index = 1
      @session_description = session_description
      @session_name = session_name
      @server = server
    end
    
    def add_set(xset)
      sets << xset
      xset.title ||= "S" + (@current_index += 1).to_s
      # binding.pry
    end
    
    def save_expression(expression)
      self.save
      session_id = @id
      Persistable.session_repository.save_expression(session_id, expression)
    end
    
    
    def remove_set(set_to_remove)
      input_set = set_to_remove.resulted_from
      generated_from_removed_set = sets.select{|set| set.resulted_from == set_to_remove}
      #Apply transitivity
      generated_from_removed_set.each{|set| set.resulted_from = set_to_remove.resulted_from}
      
      sets.delete(set_to_remove)
    end
    
    def save
      if Persistable::session_repository
        Persistable::session_repository.save_session(self)      
      end
      Persistable::repository[self.id] = self
      return true;
    end
    
  end
end