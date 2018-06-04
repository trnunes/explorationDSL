class Filter < AuxiliaryFunction 
  def accept(filter_interpreter)
    filter_interpreter.visit(self)
  end
  
  def initialize(&block)
    self.instance_eval &block
  end
  
  def method_missing(m, *args, &block)
    klass = Object.const_get m.capitalize
    operation_subclasses = ObjectSpace.each_object(Class).select { |space_klass| space_klass < Filter }
    return klass.new(*args, &block)
  end
  
end