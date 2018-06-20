
module Xplain
  class Entity
    extend Forwardable
    attr_accessor :id, :text, :server, :type
    
    def initialize(id, text="")
      @id = id
      @text = text

    end
    
    #TODO generalize it!
    def text
      if @text.to_s.empty?
        return Xplain::Namespace.colapse_uri(id)
      end
      @text
    end
        
    def add_server(server)
      @server = server
    end
  
    def to_s
      "Entity: " + @id + " : " + @text
    end
  
    def inspect
      to_s
    end
    
  
    def eql?(item)
      if !item.respond_to? :id
        return false
      end
      @id == item.id
    end    
  
    def hash
      @id.hash
    end
  
    alias == eql?
    
    def method_missing(m, *args, &block)
      RelationHandler.new(self).handle_call(m, *args, &block)
    end
  end
end
