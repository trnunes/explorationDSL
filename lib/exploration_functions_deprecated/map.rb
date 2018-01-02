module Explorable
  class Map < Explorable::Operation
    
    def prepare(args)
      @args[:function].prepare()
    end
    
    def delayed_result?
      @args[:function].delayed_result?
    end
    
    def eval_item(item)
      start_time = Time.now
      function = @args[:function]

      if(!function)
        raise "Missing mapping function!"
      end

      # function.origin_set = self
      mapped_items = function.map(item)
      

      finish_time = Time.now
      puts "EXECUTED MAP: " << (finish_time - start_time).to_s
      return mapped_items
    end
    
    def v_expression
      "Map(#{@args[:function].expression})"
    end
    
    def expression
      "#{@args[:input].id}.map(#{@args[:function].expression})"
    end
    
  end
    
  def map(args = {}, &block)
    args[:function] = yield(Mapping)
    execute_exploration_operation(Map, args)
  end
  
  def v_map(args = {}, &block)
    args[:function] = yield(Mapping)
    execute_visualization_operation(Map, args)
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