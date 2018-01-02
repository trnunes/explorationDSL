module Grouping
  class ByImage < GroupingRelation
    attr_accessor :relation, :groups_hash
    def initialize(*args)
      if(args.nil? || args.empty?)
        raise MissingRelationException
      end
      @groups_hash = {}
      @relation = args.first
    end
  
    def prepare(nodes_to_group, groups=[])
      if nodes_to_group.empty?
        return []
      end
      if relation.nil?
        raise MissingRelationException
      end
    
    end
  
    def group(nodes)
      return @relation.group_by_image(nodes)
    end
  end
end