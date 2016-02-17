require 'json'

module Readable
  def load(id)
    path = "./datasets/" + id.to_s + ".json"
    json_string = File.read(path)
    json_hash = JSON.parse(json_string)
    create(hash)
  end
  
  def create(hash)    
    obj = self.new(hash["id"])
    hash.each {|k,v| obj.send("#{k}=",v)}  
  end
  
end
  