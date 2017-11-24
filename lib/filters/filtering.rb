module Xplain
  module Filtering
    attr_accessor :filters
  
    class SimpleFilter
      attr_accessor :relation, :values
      def initialize(relation, *values)
        if(relation.nil?)
          raise "The filtering relation cannot be nil!"
        end
        if(values.compact.empty?)
          raise "You should provide at least one filtering value!"
        end
        @relation = relation
        @values = values
      end
    end
    
    class Equals < SimpleFilter
    end
  
    class Lt < SimpleFilter
    end
  
    class LtEql < SimpleFilter
    end
  
    class Grt < SimpleFilter
    end

    class GrtEql < SimpleFilter
    end
  
    class Not < SimpleFilter
    end
   
    class EqualsOne < SimpleFilter
    end
  
    class Contains < SimpleFilter
    end
    
    class CompositeFilter
      attr_accessor :filters
      def initialize(filters)
        @filters = filters
      end
    end
  
    class And < CompositeFilter
    end

    class Or < CompositeFilter
    end
  end
end
