module OperationFactory
  def method_missing(m, *args, &block)
    instance = nil

    klass = Object.const_get m.capitalize

    if !operation_class? klass
      #must be an auxiliary function call
      #TODO raise an exception in case of not being an auxiliary function
      return handle_auxiliary_function(klass, *args, &block)
    end

    if args.empty?
      args << {}
    end
    
    target_promisse = nil
    
    if set_operation? klass
      input = args.first
      args[0] = {server: server}
      target_promisse = klass.new(*args, &block)
      Xplain.get_current_workflow.chain(target_promisse, input)
    else
      args.first[:server] ||= server
      target_promisse = klass.new(*args, &block)
    end
    handle_operation_instance(target_promisse)    
    return target_promisse
  end
  
  
  def operation_class?(klass)
    operation_subclasses = ObjectSpace.each_object(Class).select {|space_klass| space_klass < Operation }
    operation_subclasses.include? klass
  end
  
  def set_operation?(klass)
    klass == Intersect || klass == Unite || klass == Diff
  end
  
  def handle_auxiliary_function(klass, *args, &block)
  end
  
  def handle_operation_instance(target_operation)
  end
end