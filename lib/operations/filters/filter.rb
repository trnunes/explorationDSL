class Filter
  def initialize(&block)
    self.instance_eval &block
  end

  def filter(nodes)
  end
  
  def method_missing(m, *args, &block)
    klass = Object.const_get m.capitalize
    operation_subclasses = ObjectSpace.each_object(Class).select { |space_klass| space_klass < Filter }
    return klass.new(*args, &block)
  end
  
end