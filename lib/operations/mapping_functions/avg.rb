module Mapping
  
  class Avg < AuxiliaryFunction
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
      avg_literal = Xplain::Literal.new(node_images.map{|img| img.item.value}.inject(0, :+)/node_images.size.to_f)
      [Node.new(avg_literal)]
    end
  end
end