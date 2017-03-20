module Mapping
  
  class Function
    attr_accessor :name, :mappings, :type, :origin_set, :result_index

    def initialize(name)
      @name = name
      @result_index = {}
      @mappings = {}
    end

    def map(xset)
    end 
    
  end
end