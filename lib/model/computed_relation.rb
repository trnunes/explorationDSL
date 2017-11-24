module Xplain
  class ComputedRelation
    include Relation
    def initialize(id = SecureRandom.uuid)
      @id = id
      @root = Entity.new(@id)
    end
  
    def fetch_graph(items)
      @root.children && items
    end
  end
end