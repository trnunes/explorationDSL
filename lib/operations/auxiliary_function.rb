class AuxiliaryFunction
  attr_accessor :args
  def initialize(*args, &block)
    @args = args
    if block_given?
      self.instance_eval &block
    end
  end
end