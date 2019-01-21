module XmapAux
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
      
      avg_literal = Xplain::Literal.new(image.map{|img| img.item.value}.inject(0, :+)/image.size.to_f)
      [Xplain::Node.new(item: avg_literal)]
    end
  end
end