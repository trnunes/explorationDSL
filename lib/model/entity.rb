
module Xplain
  class Entity
    extend Forwardable
    attr_accessor :id, :text, :server, :parent, :children, :type
    def_delegators :@children, :<<
    def initialize(id, text="")
      @id = id
      @text = text
      @children = []
    end
  
    def copy
      self_copy = Entity.new(@id)
      self_copy.text = @text
      self_copy.server = @server
      @children.each do |child|
        self_copy.add_child child.copy
      end
    
      self_copy.type = @type
      self_copy
    end
  
    def parent=(item)
      @parent = item
      item.add_child self
    end
  
    def set_parent(parent)
      @parent = parent
    end
  
    def add_child(item)
      @children << item
      item.set_parent(self)
    end
  
    def set_children(children_set)
      @children = children_set
      children_set.each{|c| c.set_parent self}
    end
  
    def add_server(server)
      @server = server
    end
  
    def to_s

      "Entity: " + @id
    end
  
    def inspect
      to_s
    end
  
    def eql?(item)
      if !item.respond_to? :id
        return false
      end
      @id == item.id
    end
  
    def hash
      @id.hash
    end
  
    alias == eql?
  end
end
