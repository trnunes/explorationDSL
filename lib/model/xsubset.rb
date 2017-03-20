class Xsubset < Xset
  attr_accessor :level, :subset_of
  
  def initialize(parent_set, level, &block)
    super(&block)
    @subset_of = parent_set
    @level = level
    yield(self) if block_given?
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