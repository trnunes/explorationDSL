class Type < Item
  def type?
    true
  end
  
  def instances    
    instances = Set.new() 
    servers.each do |server|
      instances += server.instances(self)
    end
    instances
  end
  
  def relations
    relations = Set.new()
  end
end