module Mapping
    
  def self.method_missing(function_name, options)
    mapping_function = Mapping::Function.load(function_name.to_s)
    # binding.pry
   unless mapping_function.nil?
     mapping_function.init(options)
     mapping_function
   else
     if(options[:map])
       function = Mapping::UserDefined.new(options)
       function.save
       return function
     end
     raise NoMethodError, "There is no '#{function_name}' operation"
   end
  end
  
  module Function
    include Persistable::Writable
    extend Persistable::Readable
    
  end
  
  module Aggregator
    include Function
    attr_accessor :origin_set, :name
    
    def initialize(name)
      @name = name
    end
    
    def compute(xset)
      @mappings = {}
      @set = xset
      xset.each_image do |item|

        if(item.is_a? Xsubset)

          init(@options)
          item.each do |subset_item|
            map(subset_item)
          end
         @mappings[item] = Xsubset.new(item.key){ |s| s.extension = {@aggregation => {} }}
         # binding.pry
        else
          map(item)
        end
        
      end
      if @mappings.empty?
        @mappings[@aggregation] = {}
      end
      @mappings
    end
    
    def map(item)
      #implementation in the subclass
    end
    
    def init(options = {})
      @options = options
    end
    
    def expression
    end
  end
  
  module Transformator
    include Function
    attr_accessor :origin_set, :name
    
    def initialize(name)
      @name = name
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