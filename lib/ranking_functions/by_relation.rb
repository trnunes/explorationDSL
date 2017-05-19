module Ranking
  class ByRelation < Ranking::Function
    attr_accessor :relations
    
    def initialize(relations)
      @relations = PathRelation.new(relations)
    end
    
    def prepare(args, server)
      @relations.server = server
      if(!@result_hash.nil?)
        return
      end
      @result_hash = {}
      result_pairs = @relations.restricted_image(args[:input].each_item)
      result_pairs.each do |pair|
        if(!@result_hash.has_key?(pair.domain))
          @result_hash[pair.domain] = []
        end
        @result_hash[pair.domain] << pair.image
      end
    end
    
    
    def score(item)
      if(@result_hash[item])
        image_item = @result_hash[item].first
        if(image_item.is_a? Xpair::Literal)
          image_item.value
        else
          image_item.to_s
        end
      end
    end    
    
    def expression
      relation_exp = self.relations.map{|r| r.is_a?(Xset)? r.expression : r.to_s}.join(", ")
      "by_relation(#{relation_exp})"
    end
    
    def name
      "each_image_count"
    end
  end
  
  def self.by_relation(args={})
    ByRelation.new(args[:relations])
  end
end