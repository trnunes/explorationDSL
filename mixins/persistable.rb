require 'json'

module Persistable
  def save
    File.open("./datasets/"+self.id.to_s+".json", 'w'){|f| f.write(self.to_json)}
  end
  
  def load
    
  end    
end