module Mapping
  
  class Count
    def initialize(relation)
      @relation = relation
      @images_hash = {}
    end
    
    def prepare(nodes)
      @images_hash = @relation.restricted_image(nodes).to_h
    end
      
    def visit(node)
      return [Node.new(Xplain::Literal.new(0))] if !@images_hash.has_key? node
      node_images = @images_hash[node]
      [Node.new(Xplain::Literal.new(node_images.size))]
    end
  end
end