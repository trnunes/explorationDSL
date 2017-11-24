module Xplain
  module ModelFactory
  
    def new_relation(*relations)

      relations.map!{|r| (r.is_a?(Hash))? SchemaRelation.new(id: r.values.first, inverse: true) : SchemaRelation.new(id: r)}
      if relations.size > 1
        PathRelation.new(relations: relations)
      else
        relations.first
      end
    end
  
    def new_entity(entity_id)
      Entity.new(entity_id)
    end
  
    def inverse(relation)
      {:inverse=>relation}
    end
  
    def new_literal(l_value)    
      l_value.is_a?(Hash)? Literal.new(l_value.values.first, l_value.keys.first) : Literal.new(l_value)
    end  
  end
end
