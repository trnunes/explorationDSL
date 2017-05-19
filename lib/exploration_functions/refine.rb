module Explorable
  class Refine < Explorable::Operation
    
    def prepare(args)
      @args = args
      start_time = Time.now
      result_set = Xset.new(SecureRandom.uuid, self.expression)
      start_time = Time.now      
      input_set = @args[:input]

      Filtering.set_server input_set.server
      Filtering.prepare(input_set.each_item, input_set.server)
      finish_time = Time.now
      puts "EXECUTED REFINE: " << (finish_time - start_time).to_s
      
    end
    
    def eval_item(item)
      # binding.pry
      if(!Filtering.eval_filters(item))
        return item
      end
    end
    
    def expression
      "refine(#{@args[:input].id}){#{Filtering.expression}}"
    end
  end
  
  def refine(args = {}, &block)
    yield(Filtering)
    rs = execute_operation(Refine, args)
    Filtering.clear
    rs
  end
end