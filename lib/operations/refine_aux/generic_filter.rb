class GenericFilter < AuxiliaryFunction 
  def accept(filter_interpreter)
    filter_interpreter.visit(self)
  end
  
  def initialize(&block)
    self.instance_eval &block
  end
  
  def filter(node)
    true
  end
  
  #TODO remove redundance with Operation class. Idea: move the method missing to a module
  def method_missing(m, *args, &block)
      aux_function_files = Dir[Xplain.base_dir + "operations/refine_aux/*.rb"]
      target_aux_function_file = Xplain.base_dir + "operations/refine_aux/#{m.to_s.to_underscore}.rb"
      if aux_function_files.include? target_aux_function_file
        load target_aux_function_file
        klass = Object.const_get "RefineAux::" + m.to_s.to_camel_case
        klass.new(*args, &block)
      else
        super
      end

  end
  
end