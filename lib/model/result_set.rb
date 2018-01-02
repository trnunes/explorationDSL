class ResultSet
  extend Forwardable
  attr_accessor :result_nodes
  def_delegators :@result_nodes, :map, :each, :select, :<<, :empty?, :eql, :==, :hash, :sort, :to_a

  def initialize(result_nodes = [])
    @result_nodes = result_nodes
  end
  
  def build_h(&block)
    results_hash = {}
    @result_nodes.each do |node|
      yield(node, results_hash)
    end
    results_hash
  end
  
  def to_h
    build_h{|node, results_hash| add_value(results_hash, node.parent, node)}
  end
  
  def [](index)
    @result_nodes.to_a[index]
  end
  
  def to_inverse_h
    build_h{|node, results_hash| add_value(results_hash, node, node.parent)}
  end
  
  def contain_literals?
    @result_nodes.to_a[0].is_a? Xplain::Literal
  end
  
  def uniq!
    @result_nodes = Set.new(@result_nodes)
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