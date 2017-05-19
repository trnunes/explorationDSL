module Explorable
  class Pivot < Explorable::Operation
    def prepare(args)
      if(!@result_hash.nil?)
        return
      end
      @result_hash = {}
      relations = args[:relations]
      is_backward = args[:is_backward]
      input_set = args[:input]
      
      result_pairs = Set.new
      relations.each do |r|
        if(r.server.nil?)
          r.server = @server
        end
        if(is_backward)
          result_pairs += r.restricted_domain(input_set.each_item)
        else
          result_pairs += r.restricted_image(input_set.each_item)
        end
      end
      
      result_pairs.each do |pair|
        if(!@result_hash.has_key?(pair.domain))
          @result_hash[pair.domain] = []
        end
        @result_hash[pair.domain] << pair.image
      end
    end
    
    def eval_item(item)
      result_items = []
      if(@result_hash.has_key?(item))
        result_items = @result_hash[item]
      end
      # binding.pry
      result_items
    end
    
    def expression
      SecureRandom.uuid
    end
  end
  
  def pivot(args = {})
    execute_operation(Pivot, args)
  end
  
  def pivot_forward(args = {})
    execute_operation(Pivot, args)
  end
  
  def pivot_backward(args = {})
    args[:is_backward] = true
    execute_operation(Pivot, args)
  end
end