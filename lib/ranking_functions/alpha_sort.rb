module Ranking
  class AlphaSort < Ranking::Function
    
    def score(item)
      item.text
    end    
    
    def prepare(args, server)
    end
    
    def name
      "alpha_sort"
    end
    
    def expression
      "alpha_sort"
    end
    
  end
  
  def self.alpha_rank()
    AlphaSort.new()
  end
  
end