require 'securerandom'

module Persistable
  
  @@memoryRepository = {}
  
  def self.repository
    @@memoryRepository
  end
  

end

module Persistable::Readable
  def load(id)
    Persistable::repository[id];
  end  
end

module Persistable::Writable
  def save
    self.id = SecureRandom.uuid if self.id.nil?
    Persistable::repository[self.id] = self
    return true;
  end  
end
