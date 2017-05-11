
module Grouping
  class ByDomain < Grouping::Function
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
    
    def group(set)
      mappings = {}
      are_schema_relations = !self.relations.first.is_a?(Xset)
      if(are_schema_relations)
        relations = [set.pivot_backward([self.relations])]
      else
        relations = self.relations
      end
      closest_relation = relations.last
      

      set.each_item do |item|
        # binding.pry
        
        domains = set.trace_domains(item)
        target_set_domains = domains.select{|domain| domain.first == closest_relation.id}
        target_set_domains.each do |domain_array|
          domain_array.shift()
          domain_array.each do |domain_item|
            mappings[domain_item] ||= {}
            mappings[domain_item][item] = {}
          end
        end
      end
      mappings
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
    ByDomain.new(args[:relations])
  end
end