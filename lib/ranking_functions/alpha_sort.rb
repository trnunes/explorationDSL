module Ranking
  class AlphaSort < Ranking::Function
    
    def score(item)
      item.to_s
    end    
        
    def name
      "alpha_sort"
    end
    
    def expression
      relation_exp = self.relations.map{|r| r.is_a?(Xset)? r.expression : r.to_s}.join(", ")
      "by_relation(#{relation_exp})"
    end
    
  end
  
  def self.alpha_rank()
    AlphaSort.new()
  end
  
end