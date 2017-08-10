module Explorable
  class Pivot < Explorable::Operation
    attr_accessor :queriable
    def queriable?
      @queriable
    end
    

    def prepare(args)
      if(!@result_hash.nil?)
        return
      end
      puts "-----BEGIN PREPARE----"
      @result_set = Set.new
      @result_hash = {}
      relations = args[:relations]
      is_backward = args[:is_backward]
      input_set = args[:input]
      result_pairs = []
      position = args[:position] || "image"
      items = input_set.each_item
      @limit = args[:limit] || items.size
      # @queriable = true
      relations.each do |r|
        r.server = r.server || input_set.server
        if r.is_a?(PathRelation)
          r.limit = @limit 
          # @queriable = r.can_fire_path_query
        end
        if(@limit > 5000)
          offset = 0
          local_limit = 5000
          while(local_limit < @limit) do
            result_pairs += r.restricted_image(items[0..@limit], [], args[:limit].to_i)
          end
          
        else
          result_pairs += r.restricted_image(items[0..@limit], [], args[:limit].to_i)
        end
        

      end
      puts "START PARSING PAIRS INPIVOT PREPARE"
      result_pairs.each do |pair|
        if(@result_hash[pair.domain].nil?)
          @result_hash[pair.domain] = []
        end
        @result_hash[pair.domain] << pair.image
      end
      puts "--------------FINISHED PREPARE PIVOT----------------"
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
      "Pivot(#{relationExp})"
    end
    
    def expression
      relationExp = @args[:relations].map{|r| r.text}.join(", ")
      direction = @args[:is_backward] ? "backward" : "forward"
      limit = @args[:limit] || @args[:input].each_item.size
      "#{@args[:input].id}.pivot"+direction+"(#{relationExp}, limit: #{limit.to_s})"
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