class AuxiliaryFunction
  def initialize(&block)
    if block_given?
      self.instance_eval &block
    end
  end
end