class Xsubset < Xset
  attr_accessor :level, :subset_of, :key
  
  def initialize(key, &block)
    super(&block)
    @key = key
    yield(self) if block_given?
    @id ||= SecureRandom.uuid
    self
  end
  
  def eql?(obj)
    self.class == obj.class && self.extension == obj.extension
  end
  
  def hash
    self.extension.hash
  end
  
  def to_s
    @id.to_s
  end
  alias == eql?

  
end