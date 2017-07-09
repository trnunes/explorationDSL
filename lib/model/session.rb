module Xpair
  class Session
    include Persistable::Writable
    extend Persistable::Readable
    
    attr_accessor :current_index, :id, :session_name, :session_description, :sets
    
    def initialize(id = "default", session_name = 'default', session_description = 'Default Session')
      @sets = Set.new
      @id = id
      @current_index = 1
      @session_description = session_description
      @session_name = session_name
    end
    
    def add_set(xset)
      sets << xset
      xset.title ||= "S" + (@current_index += 1).to_s
      # binding.pry
    end
    
    
    def remove_set(set_to_remove)
      input_set = set_to_remove.resulted_from
      generated_from_removed_set = sets.select{|set| set.resulted_from == set_to_remove}
      #Apply transitivity
      generated_from_removed_set.each{|set| set.resulted_from = set_to_remove.resulted_from}
      
      sets.delete(set_to_remove)
    end
    
  end
end