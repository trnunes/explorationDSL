module Mapping
  
  class Sum
    def initialize(relation)
      @relation = relation
      @images_hash = {}
    end
    
    def prepare(nodes)
      @images_hash = @relation.restricted_image(nodes).to_h
    end
      
    def visit(node)
      return [] if !@images_hash.has_key? node
      node_images = @images_hash[node]
      sum = node_images.map do |img| 
        raise NumericItemRequiredException if !img.item.is_a?(Xplain::Literal)
        img.item.value.to_f
      end.inject(0, :+)
      
      [Node.new(Xplain::Literal.new(sum))]
    end
  end
end