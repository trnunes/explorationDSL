module Xplain
  class ComputedRelation
    include Relation
    attr_accessor :domain_nodes
    def initialize(args = {})
      @id = args[:id] || SecureRandom.uuid
      @domain_nodes = args[:domain] || []
      @inverse = args[:inverse]
      @inverse ||= false
    end
      
    def fetch_graph(items, limit=nil, offset=nil)
      restricted_image(items, {limit: limit, offset: offset}).map{|item| item.parent}.uniq
    end
  
    def schema?
      false
    end
    
    def reverse
      Xplain::SchemaRelation.new(id: id, inverse: !inverse?)
    end
    
    def image(offset=0, limit=nil)
      ResultSet.new(Set.new(@domain_nodes.map{|dnode| dnode.children}.flatten))
    end
  
    def domain(offset=0, limit=-1)
      ResultSet.new(@domain_nodes.dup)
    end
  
    def restricted_image(restriction, options= {})
      ResultSet.new(Set.new((@domain_nodes & restriction).map{|dnode| dnode.children}.flatten))
    end
  
    def restricted_domain(restriction, options = {})
      intersected_image = @domain_nodes.map{|dnode| dnode.children}.flatten & restriction
      ResultSet.new(Set.new(intersected_image.map{|img_node| img_node.parent}))
    end
    
    def group_by_image(nodes)
      groups = {}

      grouped_nodes = @domain_nodes & nodes
      grouped_nodes.each do |node|
        node.children.each do |child|
          if !groups.has_key? child.item
            groups[child.item] = Node.new(child.item)
          end
          groups[child.item] << Node.new(node.item)
        end
      end
      ResultSet.new(groups.values)
    end
  
  end
end