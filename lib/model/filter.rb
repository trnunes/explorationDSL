class Filter
  require 'ripper'
  require 'sorcerer'
  def initialize(predicate_code, context=nil)
    @predicate_code = predicate_code
    @context = context
    @local_variables = eval("local_variables", context)
  end
  
  def search_and_replace(array)
    size = array.size
    size.times do |i|
      element = array[i]
      
      if element.is_a? Array
        search_and_replace(element)
      end    

      if(@local_variables.include?(element.to_s.to_sym))
        # 
        # 
        # 

         variable_value = eval(element.to_s, @context)
         
         if variable_value.is_a?(Item)
           replacement = variable_value.expression
         else
           replacement = variable_value.inspect
         end
         array[i] = replacement
      end 
    end      
  end
  
  def replace_context_variables
    @rendered_code = @predicate_code
    if(!@context.nil?)
      # 
      # 
      ast = Ripper::SexpBuilder.new(@predicate_code).parse
      # 
      # 
      search_and_replace(ast)
      @rendered_code = Sorcerer.source(ast)
      # 
            
    end
    
  end
  
  def to_source
    replace_context_variables
    "Filter.new(\"" + @rendered_code + "\")"    
  end
  
  
  def to_proc
    replace_context_variables
    
    eval("lambda{|item| " + @rendered_code + "}")   
  end
end
