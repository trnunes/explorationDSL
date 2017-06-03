module Explorable
  class Pivot < Explorable::Operation
    
    def prepare(args)
      if(!@result_hash.nil?)
        return
      end
      @result_set = Set.new
      @result_hash = {}
      relations = args[:relations]
      is_backward = args[:is_backward]
      input_set = args[:input]
      result_pairs = Set.new
      position = args[:position] || "image"
      items = input_set.each_item
      limit = args[:limit] || items.size
      relations.each do |r|

        r.server = r.server || input_set.server
        r.limit = limit if r.is_a?(PathRelation)

        if(is_backward)
          result_pairs += r.restricted_domain(items[0..limit])
        else
          result_pairs += r.restricted_image(items[0..limit])
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

      result_items
    end
    
    def v_expression
      relationExp = @args[:relations].map{|r| r.text}.join(", ")
      direction = @args[:is_backward] ? "backward" : "forward"
      "Pivot"+direction+"(#{relationExp})"
    end
    
    def expression
      relationExp = @args[:relations].map{|r| r.text}.join(", ")
      direction = @args[:is_backward] ? "backward" : "forward"
      "#{@args[:input].id}.pivot"+direction+"(#{relationExp})"
    end
    
  end
  
  def pivot(args = {})
    execute_exploration_operation(Pivot, args)
  end
  
  def v_pivot(args = {})
    execute_visualization_operation(Pivot, args)
  end
  
  
  def pivot_forward(args = {})
    execute_exploration_operation(Pivot, args)
  end
  
  def v_pivot_forward(args = {})
    execute_visualization_operation(Pivot, args)
  end
  
  
  def pivot_backward(args = {})
    args[:is_backward] = true
    execute_exploration_operation(Pivot, args)
  end
  
  def v_pivot_backward(args = {})
    args[:is_backward] = true
    execute_visualization_operation(Pivot, args)
  end
  
end