module Ranking
  class ByRelation < Ranking::Function
    attr_accessor :relations
    
    def initialize(relations)
      @relations = relations
    end
    
    def source_set=(source_set)
      @source_set = source_set
      relation_set = self.get_relation_set()
      @closest_relation = relation_set.shift
      
    end
    
    def score(item)
      
      
      if(@relation_set.size > 0)
        sort_value = @closest_relation.trace_image_items(item, @relation_set.dup).first
      else
        sort_value = @closest_relation.image_items(item).first
      end
      
      # binding.pry
      if sort_value.nil?
        return -Float::INFINITY
      end
      if sort_value.is_a? Xsubset
        sort_value.first.value
      elsif sort_value.is_a? Xpair::Literal
        sort_value.value
      else
        sort_value.to_s
      end
    end    
    
    def expression
      relation_exp = self.relations.map{|r| r.is_a?(Xset)? r.expression : r.to_s}.join(", ")
      "by_relation(#{relation_exp})"
    end
    
    #private
    def get_relation_set
      are_schema_relations = !self.relations.first.is_a?(Xset)
      if are_schema_relations
        @relation_set ||= [self.source_set.pivot_forward(relations: self.relations)]
      else
        @relation_set ||= self.source_set.order_relations(self.relations)
      end 
      @relation_set     
    end
    
    def name
      "each_image_count"
    end
  end
  
  def self.by_relation(args={})
    ByRelation.new(args[:relations])
  end
end