
module Grouping
  class ByImage < Grouping::Function
    attr_accessor :relations
    
    def horizontal?
      true
    end
    
    def initialize(args)

      
      if args.size > 0
        self.relations = args
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
    end
    
    def prepare(items_to_group)
    end
    
    def group(item, pair, groups)
      Pair.new(pair.image, pair.domain)
    end
    
    def expression
      relation_exp = ""
      relation_exp = "[" << self.relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]"
      "by_domain(#{relation_exp})"
    end  
  end
  
  def self.by_domain(args = {})
    if !args.has_key? :relations
      raise "Missing relations param!"
    end
    ByImage.new(args[:relations])
  end
end