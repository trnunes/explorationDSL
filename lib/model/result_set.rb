module Xplain
  class ResultSet
    extend Forwardable
    include Xplain::ResultSetWritable
    include Xplain::ResultSetReadable
    
    attr_accessor :intention, :nodes, :id
    def_delegators :@nodes, :each, :map, :select, :to_a, :empty?
    
    def initialize(id, nodes_list, intention = nil, annotations = [])      
      @id = id || SecureRandom.uuid      
      @nodes = nodes_list
      @intention = intention
    end
    
    def get_page()
      
    end
    
    def to_tree
      root = Node.new(@id)
      root.children = @nodes
      root
    end
    
    def build_h(&block)
      results_hash = {}
      each do |node|
        yield(node, results_hash)
      end
      results_hash
    end
    
    def to_h
      build_h{|node, results_hash| add_value(results_hash, node.parent, node)}
    end
    
    ###
    ### TODO accelerate this method by calling @nodes only the first time 
    ###
    def [](index)
      @nodes[index]
    end
    
    def to_inverse_h
      build_h{|node, results_hash| add_value(results_hash, node, node.parent)}
    end
    
    def contain_literals?
      @nodes.to_a[0].is_a? Xplain::Literal
    end
    
    def uniq!
      @nodes = Set.new(@nodes)
    end
    
    def add_value(hash, key, value)
      if(!hash.has_key?(key))
        if value.is_a? Xplain::Literal
          hash[key] = []
        else
          hash[key] = Set.new
        end
      end
      hash[key] << value
    end  
  end
end