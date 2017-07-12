
module Grouping
  class ByDomain < Grouping::Function
    attr_accessor :domain_set
    def horizontal?
      false
    end
    def initialize(args)
      if args[:domain_set]
        self.domain_set = args[:domain_set]
        
      else
        raise "Invalid number of arguments. Expected: min 1, max 2; Received: #{args.size}"
      end
           
    end
    
    def prepare(items_to_group, groups, server, args = {})
      relation = nil
      input_set = args[:input]

      
      @domain_by_image_hash = {}

      input_set.restricted_image(self.domain_set, [], args[:limit].to_i).each do |pair|
        if !@domain_by_image_hash.has_key?(pair.image)
          @domain_by_image_hash[pair.image] = Set.new
        end
        @domain_by_image_hash[pair.image] << pair.domain
      end
      
    end
    
    def group(item, groups)
      grouping_items = Set.new
      if(@domain_by_image_hash.has_key?(item))
        @domain_by_image_hash[item].each do |image_item|
          grouping_items << image_item
        end
      end
      grouping_items
    end
    
    def expression
      "by_domain(#{self.domain_set.text})"
    end  
  end
  
  def self.by_domain(args = {})
    if !args.has_key? :domain_set
      raise "Missing domain set param!"
    end
    ByDomain.new(args)
  end
end