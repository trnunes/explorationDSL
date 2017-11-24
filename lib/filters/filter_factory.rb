module Xplain
  module FilterFactory
    attr_accessor :values, :fvalue, :frelation
    include ModelFactory
    def relation(*relations)

      @frelation = new_relation(*relations)
    end
  
    def entity(entity_id)
      @fvalue = new_entity(entity_id)
    end
  
    def literal(l_value)    
      @fvalue = new_literal(l_value)
    end
  
    def entities(*entities)
      @values = entities.map!{|id| new_entity(id)}
    end
  
    def literals(*literals)    
      @values = literals.map!{|l| new_literal(l)}
    end
  
  end
end