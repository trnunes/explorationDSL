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
        xset.each do |item|
          @sum += item.value
          @count += 1
        end
        avg = Xpair::Literal.new(@sum/@count)
        mappings[avg] = {}
        result_index[xset] = {avg=>{}}
        [mappings, result_index]        
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
      xset.each do |item|
        leaves = HashHelper.leaves(xset.trace_image(item, relation_sets.dup))
        avg = Xpair::Literal.new(leaves.inject{ |sum, literal| sum.value + literal.value }.to_f/leaves.size.to_f)
        mappings[item] = {avg => {}}
      end        
      [mappings, HashHelper.copy(mappings)]
    end
  end

  def self.avg(relations=nil)
    return Average.new(relations)
  end
end