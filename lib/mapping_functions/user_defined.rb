module Mapping
  class UserDefined
    attr_accessor :id
    include Mapping::Function
    def initialize(options)

      @options = options


      init(options)
    end
    
    def init(options)
      # binding.pry
      self.class.class_eval do
        include options[:function_type]
      end
      
      @name = options[:name]
      @id = @name
      @init_code = options[:initializer]
      @map_code = options[:map]
      begin
        eval(@init_code)
      rescue Exception => e
        raise "Something went wrong with the inialization code: #{e.to_s}"
      end
    end
  
  
    def map(item)
      begin
        # binding.pry
        eval(@map_code)
      rescue Exception => e
        raise "Something went wrong with the function code: #{e.to_s}"
      end
    end
    
    def expression
      relation_exp = ""
      relation_exp = "[" << self.relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]"
      "image_count(#{relation_exp})"
    end
  end
end

# module Mapping
#   class ImageCount < Function
#     attr_accessor :relations
#
#     def initialize(relations)
#       super("image_count")
#       @image_counts = {}
#       @relations = relations
#     end
#
#
#     def map(xset)
#       if self.relations.nil?
#         return
#       end
#       relation_sets = []
#       is_schema_relation = !self.relations.first.is_a?(Xset)
#       if(is_schema_relation)
#         relation_sets << xset.pivot_forward(self.relations)
#       else
#         relation_sets = xset.order_relations(self.relations)
#       end
#       xset.each_image do |item|
#         images_count = xset.trace_image_items(item, relation_sets.dup).size
#         mappings[item] = Xpair::Literal.new(images_count)
#       end
#
#       mappings
#     end
#
#     def expression
#       relation_exp = ""
#       relation_exp = "[" << self.relations.map{|r| r.is_a?(Xset)? r.id : r.to_s}.join(",") << "]"
#       "image_count(#{relation_exp})"
#     end
#   end
#
#   def self.image_count(relations)
#
#     return ImageCount.new(relations)
#   end
# end