module Explorable
  class Map < Explorable::Operation
    
    def eval
      start_time = Time.now
      mappings = {}
      function = @args[:function]
      if(!function)
        raise "Missing mapping function!"
      end
      result_relation_index = {}
      function.origin_set = self
      mappings = function.compute(@args[:input])
      finish_time = Time.now
      puts "EXECUTED MAP: " << (finish_time - start_time).to_s
      mappings
    end
    
    def expression
      "map(#{@args[:input].id}).{#{@args[:function].expression}}"
    end
  end
    
  def map(args = {}, &block)
    args[:function] = yield(Mapping)
    execute_operation(Map, args)
  end
end
# module Explorable
#   class Map < Explorable::Operation
#
#     def eval
#       start_time = Time.now
#       mappings = {}
#       function = @args[:function]
#       if(!function)
#         raise "Missing mapping function!"
#       end
#       result_relation_index = {}
#       function.origin_set = self
#
#       if(@args[:input].has_subsets?)
#
#         @args[:input].each_image do |subset|
#           grouped_subset = subset.map{function}
#           mappings.merge! grouped_subset.extension
#         end
#       else
#         mappings = function.map(@args[:input])
#       end
#       finish_time = Time.now
#       puts "EXECUTED MAP: " << (finish_time - start_time).to_s
#       mappings
#     end
#
#     def expression
#       "map(#{@args[:input].id}).{#{@args[:function].expression}}"
#     end
#   end
#
#   def map(args = {}, &block)
#     args[:function] = yield(Mapping)
#     execute_operation(Map, args)
#   end
# end