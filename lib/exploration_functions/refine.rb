module Explorable
  class Refine < Explorable::Operation
    
    def prepare(args)
      @args = args
      start_time = Time.now
      result_set = Xset.new(SecureRandom.uuid, self.expression)
      start_time = Time.now      
      input_set = @args[:input]

      Filtering.set_server input_set.server
      if(@args[:position] == "domain")
        Filtering.prepare(input_set.each_domain, input_set.server)
      else
        Filtering.prepare(input_set.each_item, input_set.server)
      end
      
      finish_time = Time.now
      puts "EXECUTED REFINE: " << (finish_time - start_time).to_s
      
    end
    
    def eval_item(item)

      
      item_to_eval = item
      if @args[:position] == "domain"
        item_to_eval = item.index.indexing_item
      end

      if(!Filtering.eval_filters(item_to_eval))
        return item
      end
    end
    def v_expression
      "Refine(#{Filtering.expression})"
    end
    
    def expression
      "#{@args[:input].id}.refine(#{Filtering.expression})"
    end
  end
  
  def refine(args = {}, &block)
    yield(Filtering)
    rs = execute_exploration_operation(Refine, args)
    Filtering.clear
    rs
  end
  
  def v_refine(args = {}, &block)
    yield(Filtering)
    rs = execute_visualization_operation(Refine, args)
    Filtering.clear
    rs
  end
  
end