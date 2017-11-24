module Xplain
  class Xset
    include Xplain::Writeable
    extend Forwardable
  
    attr_accessor :id, :title, :relation
    def_delegators :@relation, :get_level, :count_levels, :leaves, :each_level, :<<, :restricted_image, :restricted_domain, :root
  
    def initialize(args = {}, &block)

      @id = args[:id]
      @title = args[:title]
      @items = []
      @relation = args[:relation] || ComputedRelation.new
      if block_given?
        self.instance_eval &block
      end
    end
  
  
    def copy
      self_copy = Xset.new
      r = ComputedRelation.new(root.id)
      r.root = root.copy
      #binding.pry
      self_copy.relation = r
      self_copy
    end
  
    def each(&block)
      items = []

      if relation.nested?
        items = @relation.get_level(@relation.count_levels - 1)
      else
        items = @relation.leaves
      end
      if block_given?
        items.each &block
      else
        items
      end
    end
  
    def [](index)
      @relation.leaves[index]
    end
  
    def empty?
      each.empty?
    end
      
    def method_missing(m, *args, &block)
      operation_instance = nil
      operation_klass = Object.const_get m.capitalize
      args.unshift(self)
      operation_instance = operation_klass.new(*args, &block)
      operation_instance.execute
    end
  
    def size
      each.size
    end

  end
end