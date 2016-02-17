require 'json'

module Writable
  def save
    File.open("./datasets/"+self.id.to_s+".json", 'w'){|f| f.write(self.to_json)}
  end
end