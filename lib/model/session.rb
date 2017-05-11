module Xpair
  class Session
    include Persistable::Writable
    extend Persistable::Readable
    
    attr_accessor :current_index, :id, :session_name, :session_description, :sets
    
    def initialize()
      @sets = []
      @current_index = 1
      @session_description = ""
      @session_name = ""
    end
    
    def add_set(xset)
      sets << xset
      xset.title ||= "S" + (@current_index += 1).to_s
    end
    
    def remove_set(xset)
      sets.delete(xset)
    end
    
  end
end