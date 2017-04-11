module Xpair::Graph
  attr_accessor :children, :parents
  def add_child(child)
    # @children ||= Set.new
    # children << child
    # child.add_parent(self)
  end

  def set_children(children)

    children.each do |child|
      child.add_parent(self)
    end
    @children = Set.new(children)
  end

  def add_parent(parent)
    @parents ||= Set.new
    @parents << parent
  end
  
  def self.generate_graph(hash)
    hash.each do |key, values|
      if values.is_a? Hash
        generate_graph(values)
        key.set_children(values.keys)
      else
        key.set_children(values.flatten)
      end
    end
  end
  
  def parents_hash()
    return {} if @parents.nil?
    hash = {}
    @parents.each do |parent|
      hash = parent.parents_hash
      next_items = hash
      while(!next_items.values.empty?)
        next_items = next_items.values.first
      end
      next_items[parent] = {}
    end
    return hash
  end
  
  def all_parents

    return Set.new if @parents.nil?
    parents_hash = Set.new

    @parents.each do |parent|
      parents_hash << parent      
      parents_hash += parent.all_parents
    end
    return parents_hash
  end
end
