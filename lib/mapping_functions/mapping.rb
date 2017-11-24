module Mapping
    
  def self.method_missing(function_name, options)
    mapping_function = Mapping::Function.load(function_name.to_s)

   unless mapping_function.nil?
     mapping_function.prepare(options)
     mapping_function
   else
     if(options[:map])
       function = Mapping::UserDefined.new(options)
       function.prepare(options)
       function.save
       return function
     end
     raise NoMethodError, "There is no '#{function_name}' operation"
   end
  end
  
  module Function
    include Persistable::Writable
    extend Persistable::Readable
    
    def delayed_result?
      false
    end
  end
  
  module Aggregator
    include Function
    attr_accessor :origin_set, :name
    
    def initialize(name, options = {})
      @name = name
      @aggregated_value = nil
      @options = options
    end
    
    def delayed_result?
      true
    end
    
    def map(item)
      #implementation in the subclass
    end
    
    def prepare()

    end
    
    def expression
    end
  end
  
  module Transformator
    include Function
    attr_accessor :origin_set, :name
    
    def initialize(name, options = {})
      @name = name
      @options = options
    end
    
    def compute(xset)
      @mappings = {}
      @set = xset
      xset.each do |item|

        if(item.is_a? Xsubset)
          
          item.each do |subset_item|
            @mappings[subset_item] = {map(subset_item)=>{}}
          end

        else
          @mappings[item] = {map(item)=>{}}
        end
      end
      @mappings
    end
    
    def map(item)
      #implementation in the subclass
    end
    
    def expression
    end
  end
  
end