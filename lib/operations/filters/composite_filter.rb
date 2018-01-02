class CompositeFilter < Filter
  attr_accessor :filters
  def initialize(&block)
    @filters = super &block
  end
  
end
