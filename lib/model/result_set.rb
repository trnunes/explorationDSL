module Xplain
  class ResultSet
    extend Forwardable
    include Xplain::ResultSetWritable
    extend Xplain::ResultSetReadable
    
    attr_accessor :intention, :nodes, :id
    def_delegators :@nodes, :each, :map, :select, :to_a, :empty?
    
    def initialize(id, nodes_list, intention = nil, annotations = [])
      @id = id || SecureRandom.uuid            
      input_is_list_of_items = !nodes_list.first.is_a?(Node)
      @nodes = 
        if input_is_list_of_items
          nodes_list.map{|item| Node.new(item)}          
        else
          nodes_list
        end
      @intention = intention
      to_tree
    end
    
    def resulted_from
      inputs = []
      if @intention
        inputs = @intention.get_inputs
      end
      inputs
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
  #TODO It search for all occurrences and not only the first. change the name!    
    def search_first(item_id)
      nodes_found = []
      nodes_to_search = @nodes
      while !nodes_to_search.empty?
        nodes_found += nodes_to_search.select do |node|
          comparison_value =
            if node.item.is_a? Xplain::Literal
              node.item.value
            else
              node.item.id
            end
          comparison_value == item_id
        end
        continue_search = !nodes_found.empty?
        if continue_search
          nodes_to_search = nodes_to_search.map{|node| node.children}.flatten
        end        
      end
      nodes_found
    end
    
    def include_node?(node_id)
      nodes_found = []
      nodes_to_search = @nodes
      while !nodes_to_search.empty?
        nodes_found += nodes_to_search.select{|node| node.id == node_id}
        if !nodes_found.empty?
          return true
        end
        nodes_to_search = nodes_to_search.map{|node| node.children}.flatten        
      end
      return false
    end
    
    def method_missing(m, *args, &block)

      instance = nil
      klass = Object.const_get m.to_s.to_camel_case
  
      if !Operation.operation_class? klass
        raise NameError.new("Operation #{klass.to_s} not supported!")           
      end
      if args.nil?
        args = []
      else
        args.unshift([])
      end
      
      args[0] << self
      target_promisse = klass.new(*args, &block)
          
      return target_promisse
    end  
  end
  
  
end