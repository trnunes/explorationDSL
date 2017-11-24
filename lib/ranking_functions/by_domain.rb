module Ranking
  class ByDomain < Ranking::Function
    def domain_rank?
      true
    end
    
    def score(item)
      domain = item.domain

      if(domain.is_a?(Xpair::Literal))
        domain.value
      else
        domain.to_s
      end
    end    
    
    def prepare(args, server)
    end
    
    def name
      "by_domain"
    end
    
    def expression
      "by_domain"
    end
  end
  
  def self.by_domain()
    ByDomain.new()
  end
  
end