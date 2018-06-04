module Mapping
  
  class Count < AuxiliaryFunction
    def initialize(relation=nil)
      @relation = relation
      @images_hash = {}
    end
    
    def prepare(nodes)
      @images_hash =
        if @relation
          @relation.group_by_domain_hash(nodes)
        else
          nodes.map{|node| [node, node.children]}.to_h
        end      
    end
      
    def visit(node)
      return [Node.new(Xplain::Literal.new(0))] if !@images_hash.has_key? node
      node_images = @images_hash[node]
      [Node.new(Xplain::Literal.new(node_images.size))]
    end
  end
end