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
  
  def method_missing(m, *args, &block)

    begin
        klass = Object.const_get "Filter::" + m.to_s.to_camel_case
    rescue LoadError

      if self.class.function_module

        Dir[Xplain.base_dir + "operations/filter/" + m.to_s.to_underscore + ".rb"].each {|file| require file }

        klass = Object.const_get self.class.function_module.to_camel_case + "::" + m.to_s.to_camel_case
      end
    end


    operation_subclasses = ObjectSpace.each_object(Class).select { |space_klass| space_klass < GenericFilter }
    return klass.new(*args, &block)
  end
  
end