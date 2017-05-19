module Ranking
  class ByImage < Ranking::Function
    
    def score(item)
      if(item.is_a?(Xpair::Literal))
        item.value
      else
        item.to_s
      end
    end
    
    def domain_rank?
      true
    end
    
    def prepare(args, server)
    end
    
    def name
      "by_image"
    end
    
    def expression
      "by_image()"
    end
  end
  
  def self.by_image()
    ByImage.new()
  end
  
end