module Xplain
  class Type < Xplain::Entity
    def instances    
      instances = Set.new() 
      servers.each do |server|
        instances += server.instances(self)
      end
      instances
    end
    
    def expression
      "Xplain::Type.new(\"" + @id + "\")"
    end
    
    def to_s
      'Type: ' + self.id
    end
    
  end
end