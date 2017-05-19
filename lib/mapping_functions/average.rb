module Mapping
  class Average
    include Mapping::Aggregator
    def initialize(options = {})
      super("avg", options)
    end
    
    def prepare(options = {})
      @sum = 0
      @count = 0
      @aggregated_value = Xpair::Literal.new(0)
    end
    
    def map(item)
      # binding.pry
      if(!item.is_a? Xpair::Literal)
        raise "Mapping function should receive only literals as arugments! (#{item.inspect})"
      end
      @sum += item.value.to_f
      @count += 1
      @aggregated_value.value = Xpair::Literal.new(@sum.to_f/@count.to_f).value
      @aggregated_value
      # binding.pry
    end
    
    def expression
      "avg"
    end
  end

  def self.avg(options = {})
    return Average.new(options)
  end
end

# module Mapping
#   class Average < Function
#
#     attr_accessor :relations
#
#     def initialize(relations)
#       super("avg")
#       @sum = 0
#       @count = 0
#       @relations = relations
#     end
#
#     def map(xset)
#       if self.relations.nil?
#         xset.flatten.each_item do |item|
#           @sum += item.value.to_f
#           @count += 1
#         end
#         avg = Xpair::Literal.new(@sum.to_f/@count.to_f)
#         mappings[xset] = avg
#         mappings
#       else
#         self.relations_map(xset)
#       end
#     end
#
#     def relations_map(xset)
#       are_schema_relations = !self.relations.first.is_a?(Xset)
#       relation_sets = []
#       if(are_schema_relations)
#         relation_sets << xset.pivot_forward(self.relations)
#       else
#         relation_sets = self.relations
#       end
#       xset.each_image do |item|
#         leaves = xset.trace_image_items(item, relation_sets.dup)
#         avg = Xpair::Literal.new(leaves.inject{ |sum, literal| sum.value + literal.value }.to_f/leaves.size.to_f)
#         mappings[item] = avg
#       end
#       mappings
#     end
#
#     def expression
#       "avg"
#     end
#   end
#
#   def self.avg(relations=nil)
#     return Average.new(relations)
#   end
# end