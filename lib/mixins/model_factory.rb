module Xplain
  module EntityFactory
  
  
    def new_entity(entity_id)
      if entity_id.to_s.empty?
        return nil
      end
      Entity.new(entity_id)
    end
  
    def new_literal(l_value)
      l_value.is_a?(Hash)? Literal.new(l_value.keys.first, l_value.values.first) : Literal.new(l_value)
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
      relations.map! do |r_spec|
        relation_instance = r_spec
        if r_spec.is_a? String
          relation_instance = SchemaRelation.new(id: r_spec)
        elsif r_spec.is_a? Hash
          if r_spec.has_key? :inverse
            r_info = r_spec[:inverse]
            if r_info.respond_to?(:reverse) && !r_info.is_a?(String)
              relation_instance = r_info.reverse
            elsif r_info.is_a? String
              relation_instance = SchemaRelation.new(id: r_info, inverse: true)
            elsif r_info.is_a? Hash
              relation_instance = SchemaRelation.new(r_info)
            end               
          else
            relation_instance = SchemaRelation.new(r_spec)
          end  
        end
        relation_instance
      end
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
