
module Grouping
  class ByRelation < Grouping::Function
    attr_accessor :relations
    def horizontal?
      false
    end
    def initialize(args)
      if args.size > 0
        self.relations = args
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end      
    end
    
    def prepare(items_to_group, groups, server)
      relation = nil
      if self.relations.size > 1
        self.relations.each{|r| r.server = server if r.server.nil?}
        relation = PathRelation.new(self.relations)
      else
        relation = self.relations.first
        relation.server = server if relation.server.nil?
      end
      
      @image_by_domain_hash = {}
      # binding.pry
      relation.restricted_image(items_to_group).each do |pair|
        if !@image_by_domain_hash.has_key?(pair.domain)
          @image_by_domain_hash[pair.domain] = []
        end
        @image_by_domain_hash[pair.domain] << pair.image
      end
      
    end
    
    def group(item, groups)
      grouping_items = Set.new
      # binding.pry
      if(@image_by_domain_hash.has_key?(item))
        @image_by_domain_hash[item].each do |image_item|
          grouping_items << image_item
        end
      end
      grouping_items
    end
    
    def expression
      relation_exp = ""
      relation_exp = "[" << self.relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]"
      "by_domain(#{relation_exp})"
    end  
  end
  
  def self.by_relation(args = {})
    if !args.has_key? :relations
      raise "Missing relations param!"
    end
    ByRelation.new(args[:relations])
  end
end