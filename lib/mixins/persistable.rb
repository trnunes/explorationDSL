require 'securerandom'

module Persistable
  
  @@memoryRepository = {}
  @@session_repository = nil
  
  def self.repository
    @@memoryRepository
  end
  
  def self.set_session_repository(repository)
    @@session_repository = repository
  end
  
  def self.session_repository
    @@session_repository
  end

end

module Persistable::Readable
  def load(id)
    Persistable::repository[id];
  end  
end

module Persistable::Writable
  def save
    # binding.pry
    self.id = SecureRandom.uuid if self.id.nil?
    Persistable::repository[self.id] = self
    return true;
  end   
end
