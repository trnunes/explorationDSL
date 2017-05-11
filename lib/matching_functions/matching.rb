module Matching
    
  def self.method_missing(function_name, options)
    matching_function = Matching::Function.load(function_name.to_s)
    # binding.pry
   unless matching_function.nil?
     matching_function.init(options)
     matching_function
   else
     if(options[:match])
       function = Matching::UserDefined.new(options)
       function.save
       return function
     end
     raise NoMethodError, "There is no '#{function_name}' operation"
   end
  end
  
  module Function
    include Persistable::Writable
    extend Persistable::Readable
    
    def match()
  end
  
end