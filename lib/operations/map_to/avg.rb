module MapTo
  class Avg < AuxiliaryFunction
    include Xplain::RelationFactory
    
    def initialize(*args, &block)
      super(&block)
      if !@relation
        @relation = args.first
      end
      @images_hash = {}
    end
    
    #TODO Treat the case of relation not specified: it should use the input set as the relation
    #TODO generalize the visitor operations
    def prepare(nodes)
      @images_hash = @relation.restricted_image(nodes).to_item_h
    end
      
    def visit(node)
      return [] if !@images_hash.has_key? node.item
      node_images = @images_hash[node.item]
      avg_literal = Xplain::Literal.new(node_images.map{|img| img.value}.inject(0, :+)/node_images.size.to_f)
      [Node.new(avg_literal)]
    end
  end
end