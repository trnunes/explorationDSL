module Explorable
  class Refine < Explorable::Operation
    
    def eval
      start_time = Time.now      
      input_set = @args[:input]
      mappings = {}
      if(input_set.has_subsets? && @args[:apply_to_subsets])
        input_set.each_image do |subset|
          subset_mappings = Filtering.eval_filters(subset)
          mappings[subset] = Xsubset.new(subset.key){|s| s.server = input_set.server; s.extension = subset_mappings}
        end
      else
        mappings = Filtering.eval_filters(input_set)
      end
      Filtering.clear
      finish_time = Time.now
      puts "EXECUTED REFINE: " << (finish_time - start_time).to_s
      return mappings
    end
    
    def expression
      "refine(#{@args[:input].id}){#{Filtering.expression}}"
    end
  end
  
  def refine(args = {}, &block)
    yield(Filtering)
    execute_operation(Refine, args)
  end
end