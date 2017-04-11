module Mapping
  class Average < Function
    
    attr_accessor :relations
    
    def initialize(relations)
      super("avg")
      @sum = 0
      @count = 0
      @relations = relations
    end
    
    def map(xset)
      if self.relations.nil?
        xset.flatten.each_item do |item|
          @sum += item.value
          @count += 1
        end
        avg = Xpair::Literal.new(@sum.to_f/@count.to_f)
        mappings[xset] = avg
        mappings
      else
        self.relations_map(xset)
      end
    end
    
    def relations_map(xset)
      are_schema_relations = !self.relations.first.is_a?(Xset)
      relation_sets = []
      if(are_schema_relations)
        relation_sets << xset.pivot_forward(self.relations)
      else
        relation_sets = self.relations
      end
      xset.each_image do |item|
        leaves = xset.trace_image_items(item, relation_sets.dup)
        avg = Xpair::Literal.new(leaves.inject{ |sum, literal| sum.value + literal.value }.to_f/leaves.size.to_f)
        mappings[item] = avg
      end        
      mappings
    end
  end

  def self.avg(relations=nil)
    return Average.new(relations)
  end
end