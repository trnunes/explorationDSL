module GroupAux
  class ByImage < GroupingRelation  
    include Xplain::RelationFactory
    
    attr_accessor :groups_hash
    def initialize(*args, &block)
      super(&block)
      @groups_hash = {}
      if !block_given?
        @relation = args.first
      end    
    end
  
    def prepare(nodes_to_group, groups=[])
      if nodes_to_group.empty?
        return []
      end
      if @relation.nil?
        raise MissingRelationException
      end
    
    end
  
    def group(nodes)
      return @relation.group_by_image(nodes)
    end
  end
end
