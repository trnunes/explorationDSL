module Xplain
  module FilterFactory
    attr_accessor :values, :frelation
    include EntityFactory
    include RelationFactory
    
    def relation(*relations)

      @frelation = new_relation(*relations)
    end
  
    def entity(entity_id)
      @values = [new_entity(entity_id)]
    end
  
    def literal(l_value)    
      @values = [new_literal(l_value)]
    end
  
    def entities(*entities)
      @values = entities.map!{|id| new_entity(id)}
    end
  
    def literals(*literals)    
      @values = literals.map!{|l| new_literal(l)}
    end
  
  end
end