class ModelConfig
  def meta_relation(relation)
    @meta_model_map[:image_of] = SchemaRelation.new(id: relation.to_s)
    @meta_model_map[:domain_of] = SchemaRelation.new(id: relation.to_s, inverse: true)
  end
  
  def typing_relation(relation)
    @meta_model_map[:types] = SchemaRelation.new(id: relation.to_s)
    @meta_model_map[:types_of] = SchemaRelation.new(id: relation.to_s, inverse: true)
  end
  

end