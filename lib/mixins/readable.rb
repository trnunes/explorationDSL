require 'json'
module Persistable
  
  module Readable
  
    @@memoryRepository = {}
  
    def load(id)
      path = "./datasets/" + id.to_s + ".json"
      json_string = File.read(path)
      json_hash = JSON.parse(json_string)
      create(hash)
    end  
  end
end