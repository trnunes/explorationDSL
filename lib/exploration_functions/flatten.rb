module Explorable
  class Flatten < Explorable::Operation
    
    def eval
      start_time = Time.now
      mappings = {}
    
      @args[:input].each_item do |item|
        mappings[item] = item
      end
      finish_time = Time.now
      puts "EXECUTED FLATTEN: " << (finish_time - start_time).to_s
      return mappings
    end
    
    def expression
      "flatten(#{@args[:input].id})"
    end
  end
  
  
  def flatten(args = {})
    execute_operation(Flatten, args)
  end
end