module Mapping
  class ImageCount < Function
    attr_accessor :relations
  
    def initialize(relations)
      super("image_count")
      @image_counts = {}
      @relations = relations
    end
  
  
    def map(xset)
      if self.relations.nil?
        return
      end
      relation_sets = []
      is_schema_relation = !self.relations.first.is_a?(Xset)
      if(is_schema_relation)
        relation_sets << xset.pivot_forward(self.relations)
      else
        relation_sets = xset.order_relations(self.relations)
      end
      xset.each do |item|
        images_count = HashHelper.leaves(xset.trace_image(item, relation_sets.dup)).size
        mappings[item] = {Xpair::Literal.new(images_count) => {}}
      end        
      
      [mappings, HashHelper.copy(mappings)]
    end
  end

  def self.image_count(relations)

    return ImageCount.new(relations)
  end
end