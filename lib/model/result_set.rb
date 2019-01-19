module Xplain
  class ResultSet
    extend Forwardable
    include Xplain::ResultSetWritable
    extend Xplain::ResultSetReadable
    include Xplain::DslCallable
    
    attr_accessor :intention, :nodes, :id, :inverse, :annotations, :title
    def_delegators :@nodes, :each, :map, :select, :empty?, :size, :uniq, :sort
    def_delegators :@root_node, :children, :to_hash_children_node_by_item, :append_children, :<<, :count_levels
    
    
    def initialize(id, nodes_list, intention = nil, title = nil, annotations = [], inverse=false)
      @id = id 
      input_is_list_of_items = nodes_list && !nodes_list.first.is_a?(Xplain::Node)
      @nodes = 
        if input_is_list_of_items
          nodes_list.map{|item| Xplain::Node.new(item)}          
        else
          nodes_list
        end
      
      @intention = intention
      @inverse = inverse
      @annotations = annotations
      @root_node = Xplain::Node.new()
      @root_node.children = @nodes
      @title = title || "Set #{Xplain::ResultSet.count + 1}"
    end
    
    def inverse?
      @inverse
    end
        
    def resulted_from
      inputs = []
      if @intention && !@intention.is_a?(String)
        inputs = @intention.inputs
      end
      inputs || []
    end
    
    def breadth_first_search(all_occurrences=true, &block)
      nodes_found = []
      nodes_to_search = @nodes
      while !nodes_to_search.empty?
        nodes_found += nodes_to_search.select do |node|
          yield(node)
        end
        
        if !nodes_found.empty? && !all_occurrences
          return [nodes_found.first]
        end
        
        nodes_to_search = nodes_to_search.map{|node| node.children}.flatten
      end
      nodes_found
  
    end
    
    def history
      history_sets = []
      if !resulted_from.empty?
        history_sets += resulted_from.map{|rs| rs.history}.flatten(1)
        history_sets += resulted_from
      end
      
      history_sets
    end
    
    def copy
      copied_root = @root_node.copy
      copied_root.children.each{|c| c.parent_edges = []}
      Xplain::ResultSet.new(self.id, copied_root.children, @intention, @title, @annotations, @inverse)
    end
    
    def get_page(total_items_by_page, page_number)
      if @nodes.is_a? Set
        @nodes = @nodes.to_a
      end
      pg_offset = 0
      
      total_of_pages = count_pages(total_items_by_page)
      page_nodes = []
      limit = total_items_by_page
      if total_items_by_page > self.size
        limit = self.size
      end
      if (page_number > 0)
        pg_offset = (page_number - 1) * total_items_by_page
        page_nodes = @nodes[pg_offset..(pg_offset + limit - 1)]
      end
      page_nodes
    end
    
    #TODO generalize all computed relation methods using a mixin!
    def restricted_image(restriction, options={})
      #TODO implement the group_by_domain option!
      if inverse?
        return compute_restricted_domain(restriction)
      end
      return compute_restricted_image(restriction)
    end

    def restricted_domain(restriction, options={})
      #TODO implement the group_by_domain option!
      if inverse?
        return compute_restricted_image(restriction)
      end
      return compute_restricted_domain(restriction)
    end
    
    def compute_restricted_image(restriction)
      restriction_items = Set.new(
        restriction.map do |res_item|
          if res_item.respond_to? :item
            res_item.item  
          else
            res_item
          end
        end
      )
      #TODO implement the group_by_domain option!
      image = @nodes.select{|node| restriction_items.include? node.item}.map{|node| node.children}.flatten.compact
      Xplain::ResultSet.new(nil, image)
    end
    
    def compute_restricted_domain(restriction)
      items_set = Set.new(restriction.map{|node| node.item})
      intersected_image = @nodes.map{|dnode| dnode.children}.flatten.select{|img_node| items_set.include? img_node.item}
      ResultSet.new(nil, Set.new(intersected_image.map{|img_node| img_node.parent}))
    end
    
    def reverse()
      Xplain::ResultSet.new(nil, @nodes, @intention, @title, @annotations, !inverse?)
    end
    
    def to_tree
      @root_node
    end
    
    def get_level(level)
      to_tree.get_level(level)      
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
    
    def to_item_h
      build_h{|node, results_hash| add_value(results_hash, node.parent.item, node.item)}
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
   
   #TODO find a better place for uniq and sort operations
    def uniq
      items_hash = {}
      @nodes.each do |node|
        #TODO IMPLEMENT A SHALLOW CLONE METHOD
        items_hash[node.item] = Xplain::Node.new node.item
      end
      Xplain::ResultSet.new(@id.to_s + "_uniq", items_hash.values)
    end
    
    def uniq!
      items_hash = {}
      @nodes.each do |node|        
        items_hash[node.item] = node
      end

      @nodes = items_hash.values
      self
    end
    
    def sort(desc=true)
      Xplain::ResultSet.new(@id.to_s + "_sorted", @nodes.sort do|n1, n2|
        comparator = 
          if (n1.item.is_a?(Xplain::Literal) && n2.item.is_a?(Xplain::Literal) && n1.item.numeric? && n2.item.numeric?)
             
            n1.item.value.to_f <=> n2.item.value.to_f
          else
            n1.item.text <=> n2.item.text
          end
        if desc
          -comparator
        else
          comparator 
        end
      end)
    end
    
    def sort_asc
      sort(false)
    end
    
    def sort!
      @nodes = self.sort.nodes
      self
    end
    
    def sort_asc!
      @nodes = self.sort_asc.nodes
      self
    end
    
    def count_pages(total_by_page)
      if total_by_page == 0
        return 0
      end
    
      (size.to_f/total_by_page.to_f).ceil
    end
    
    def inspect()
      @nodes.inject{|concat_string, node| concat_string.to_s + ", #{node.item.text}"}
    end
    
  end
end