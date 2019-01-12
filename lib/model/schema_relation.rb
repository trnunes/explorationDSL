module Xplain
  class SchemaRelation
    
    include Xplain::Relation
    include Xplain::GraphConverter
    
    attr_accessor :id, :server, :root, :inverse, :cursor
    @@meta_relations = [:relations, :has_type, :relations_domain, :relations_image]
    def initialize(args={})
      @id = args[:id]
      @text = args[:text]
      @server = server
      @inverse = args[:inverse] || false
      @server = args[:server] || Xplain.default_server
      @root = Node.new(self)
    end
    
    def meta_relation?
      @@meta_relations.include? @id.to_sym      
    end    
   
    def schema?
      true
    end
    
    def text
      text_to_return = @text.to_s
      text_to_return = @id.dup.to_s if text_to_return.empty?
      text_to_return << " of" if inverse?
      text_to_return      
    end
    
    def inverse?
      @inverse
    end
    
    def reverse
      Xplain::SchemaRelation.new(id: id, inverse: !inverse?)
    end
    
    def image(offset=0, limit=nil)
      if meta_relation?
        result_graph = 
          if inverse?            
            to_nodes(@server.send((@id + "_domain").to_sym, offset: offset, limit: limit))
          else
            to_nodes(@server.send((@id + "_image").to_sym, offset: offset, limit: limit))
          end
        return Xplain::ResultSet.new(nil, result_graph)
      end
      Xplain::ResultSet.new(nil, hash_to_graph(@server.image(self, offset.to_i, limit.to_i)))
    end
  
    def domain(offset=0, limit=-1)
      if meta_relation?
        result_graph = 
          if inverse?
            to_nodes(@server.send((@id + "_image").to_sym, offset: offset, limit: limit))
          else
            to_nodes(@server.send((@id + "_domain").to_sym, offset: offset, limit: limit))
          end
        return Xplain::ResultSet.new(nil, result_graph)
      end

      Xplain::ResultSet.new(nil, hash_to_graph(@server.domain(self, offset, limit)))
    end
  
    def restricted_image(restriction, options= {})
      options[:restriction] = restriction
      options[:relation] = self
      if meta_relation?
        result_graph = 
          if inverse?            
            to_nodes(@server.send((@id + "_restricted_domain").to_sym, options))
          else
            to_nodes(@server.send((@id + "_restricted_image").to_sym, options))
          end
          return Xplain::ResultSet.new(nil, result_graph)
      end
      
      result_graph = hash_to_graph(@server.restricted_image(options), !options[:group_by_domain])
      
      Xplain::ResultSet.new(nil, result_graph)
    end
  
    def restricted_domain(restriction, options = {})
      
      options[:restriction] = restriction
      options[:relation] = self
      
      if meta_relation?   
        result_graph = 
          if inverse?
            to_nodes(@server.send((@id + "_restricted_image").to_sym, options))
          else
            
            to_nodes(@server.send((@id + "_restricted_domain").to_sym, options))
          end
        #TODO remove the nil parameter in ResultSet.new(nil, ..)
        return Xplain::ResultSet.new(nil, result_graph)        
      end
      domain_nodes = hash_to_graph(@server.restricted_domain(options))
      Xplain::ResultSet.new(nil, domain_nodes)
    end
    
    def group_by_domain_hash(nodes)
      results_hash = {}
      options = {}
      options[:restriction] = nodes
      options[:relation] = self

      #TODO implement the group_by for meta-relations
      images_hash = @server.restricted_image(options)
      images_hash.each do |key_item, related_items|
        #TODO define the roles of each component e.g. relations should return nodes or items?
        results_hash[key_item] = related_items.map{|related_item| Node.new(related_item)}
      end
      results_hash
    end
    
    def group_by_image(nodes)
      result_nodes = 
        if meta_relation?
          #TODO implement the group_by for meta-relations
          hash_to_graph(@server.send(("_group_by_" + @id + "_image").to_sym, nodes))
        else
          hash_to_graph(@server.group_by(nodes, self))
        end
      
      Xplain::ResultSet.new(nil, result_nodes)
    end
  end
end