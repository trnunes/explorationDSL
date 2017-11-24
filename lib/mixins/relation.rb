module Xplain 
  
  module Relation
    attr_accessor :root, :text
    
    def domain(offset=0, limit=nil)
    end
    
    def image(offset=0, limit=nil)
    end
    
    def restricted_domain(restriction, options={})
    end
    
    def restricted_image(restriction, options={})
    end
    
    def deep_copy
    end
    
    def inverse?
    end
    
    def eql?(relation)
    end
    
    alias == eql?
  end
end