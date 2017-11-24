require 'json'
module Xplain
  module Writable  
          
    def <<(item)
      node = Node.new(item)
      @root.children << node
      node.parent = @root
    end
    
    def save
      File.open("./datasets/"+self.id.to_s+".json", 'w'){|f| f.write(self.to_json)}
    end
  end
end