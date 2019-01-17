module XmapAux
  class Count < AuxiliaryFunction
    include Xplain::RelationFactory
    
    def initialize(*args, &block)
      super(&block)
      if !@relation
        @relation = args.first
      end
      @images_hash = {}
    end
    
    def prepare(nodes)
      @images_hash =
        if @relation
          @relation.group_by_domain_hash(nodes)
        else
          #TODO: No need for children.map!
          nodes.map{|node| [node, node.children.map{|child_node| child_node}]}.to_h
        end
    end
      
    def visit(node)
      image = @relation.nil? ? @images_hash[node] : @images_hash[node.item]
      return [Node.new(Xplain::Literal.new(0))] if !image
      [Node.new(Xplain::Literal.new(image.size))]
    end
  end
end