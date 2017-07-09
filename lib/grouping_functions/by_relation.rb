
module Grouping
  class ByRelation < Grouping::Function
    attr_accessor :relations
    def horizontal?
      false
    end
    def initialize(args)
      if args[:relations].size > 0
        self.relations = args[:relations]
        
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end
           
    end
    
    def prepare(items_to_group, groups, server, args = {})
      relation = nil
      image_set = []


      image_set = args[:image_set] || []
      if !image_set.empty?
        image_set = image_set.each_item
      end
      # binding.pry

      if self.relations.size > 1
        self.relations.each{|r| r.server = server if r.server.nil?}
        relation = PathRelation.new(self.relations)
      else
        relation = self.relations.first
        relation.server = server if relation.server.nil?
      end
      
      @image_by_domain_hash = {}
      # binding.pry
      relation.restricted_image(items_to_group, image_set, args[:limit].to_i).each do |pair|
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
      "by_relation(#{self.relations.first.text})"
    end  
  end
  
  def self.by_relation(args = {})
    if !args.has_key? :relations
      raise "Missing relations param!"
    end
    ByRelation.new(args)
  end
end