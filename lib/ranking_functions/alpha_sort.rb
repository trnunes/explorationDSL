module Ranking
  class AlphaSort < Ranking::Function
    
    def score(item)
      item.to_s
    end    
        
    def name
      "alpha_sort"
    end
  end
  
  def self.alpha_rank()
    AlphaSort.new()
  end
end