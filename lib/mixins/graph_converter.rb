module Xplain
  module GraphConverter
    
    def hash_to_graph(items_hash, return_image = false)
      nodes = []      
      items_hash.each do |item, relations|
        children_set = 
          if relations.is_a? Hash
            hash_to_graph(relations)
          else
            relations.map do |related_item|          
              related_node = Node.new(related_item)
              nodes << related_node if return_image
              related_node
            end
          end
        node = Node.new(item)
        node.children = children_set
        nodes << node unless return_image
      end
      if return_image && !nodes.first.is_a?(Xplain::Literal)
        return Set.new(nodes)
      else
        nodes
      end   
    end
    
    def to_nodes(items_list)
      items_list.map{|item| Node.new(item)}
    end
  end
end