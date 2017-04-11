
module Grouping
  class ByRelation < Grouping::Function
    attr_accessor :relations
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
        query = set.server.begin_nav_query do |q|
          set.each_item do |item|
            q.on(item)

          end
          q.restricted_image(self.relations.first)
        end

        results_hash = query.execute

        results_hash.each do |subject, relations|
          if !relations.empty?

            group_relation = relations.keys.first 

            objects = results_hash[subject][group_relation]

            objects ||= []
            objects.each do |object|
              if mappings[object].nil?
                mappings[object] ||={}
              end
              mappings[object] ||= {}
              mappings[object][subject] = {}
            end
          end
        end        
      else
        relations = set.order_relations(self.relations)
        set.each_item do |item|
          set.trace_image_items(item, relations.dup).each do |grouping_item|
            if !mappings.has_key? grouping_item
              mappings[grouping_item] = {}
            end
            mappings[grouping_item][item] = {}
          end
        end
      end

      mappings
    end
    
    def expression
      "by_relation(#{self.relations.map{|r| "'" << r.to_s << "'"}.inspect})"
    end  
  end
  
  def self.by_relation(args = {})
    if !args.has_key? :relations
      raise "Missing relations param!"
    end
    ByRelation.new(args[:relations])
  end
end