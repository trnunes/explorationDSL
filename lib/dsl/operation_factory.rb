class OperationFactory
  include Xplain::RelationFactory
  
  
  def method_missing(m, *args, &block)
    instance = nil
    klass = Object.const_get m.capitalize
    operation_subclasses = ObjectSpace.each_object(Class).select { |space_klass| space_klass < Operation }
    if operation_subclasses.include? klass
      args.unshift(self)
      if args[1].nil?
        args[1] = @server
      end
      return klass.new(*args, &block)
    else
      @auxiliar_function = klass.new(*args, &block)
    end
  end
  
end