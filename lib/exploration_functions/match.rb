module Explorable
  class Match < Explorable::Operation
    
    def eval
      start_time = Time.now
      mappings = {}
      function = @args[:function]
      input_set = @args[:input]
      target_set = @args[:target]
      
      if(!function)
        raise "Missing matching function!"
      end
      
      result_relation_index = {}
      
      if input_set.has_subsets?
      mappings = function.match(@args[:input])
      finish_time = Time.now
      puts "EXECUTED MAP: " << (finish_time - start_time).to_s
      mappings
    end
    
    def expression
      "map(#{@args[:input].id}).{#{@args[:function].expression}}"
    end
  end
    
  def map(args = {}, &block)
    args[:function] = yield(Matching)
    execute_operation(Match, args)
  end
end