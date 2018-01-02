module Xplain
  module EntityFactory
  
  
    def new_entity(entity_id)
      if entity_id.to_s.empty?
        return nil
      end
      Entity.new(entity_id)
    end
  
    def new_literal(l_value)    
      l_value.is_a?(Hash)? Literal.new(l_value.values.first, l_value.keys.first) : Literal.new(l_value)
    end  
  end
  
  module RelationFactory
    attr_accessor :relation
    
    def relation(*relations)
      @relation = new_relation(*relations)
    end
    
    def new_relation(*relations)
      relations = relations.select{|r| !r.to_s.empty?}
      if relations.empty?
        return nil
      end
      
      relations.map!{|r| (r.is_a?(Hash))? SchemaRelation.new(id: r.values.first, inverse: true) : SchemaRelation.new(id: r)}
      if relations.size > 1
        PathRelation.new(relations: relations)
      else
        relations.first
      end
    end
    
    def inverse(relation)
      {:inverse=>relation}
    end
    
  end
end
