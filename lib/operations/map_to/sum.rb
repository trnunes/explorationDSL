module MapTo
  class Sum < AuxiliaryFunction
    include Xplain::RelationFactory
    
    def initialize(*args, &block)
      super(&block)
      if !@relation
        @relation = args.first
      end
      @images_hash = {}
    end
    
    def prepare(nodes)
      @images_hash = @relation.restricted_image(nodes).to_item_h
    end
      
    def visit(node)
      return [] if !@images_hash.has_key? node.item
      node_images = @images_hash[node.item]
      sum = node_images.map do |img| 
        raise NumericItemRequiredException if !img.is_a?(Xplain::Literal)
        img.value.to_f
      end.inject(0, :+)
      
      [Node.new(Xplain::Literal.new(sum))]
    end
  end
end