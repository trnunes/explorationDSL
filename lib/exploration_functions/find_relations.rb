module Explorable
  class FindRelations < Explorable::Operation   
    
    def delayed_result?
      true
    end
    
    
    def prepare(args)
      start_time = Time.now
      @result_set = Set.new
      out_limit = args[:out_limit] || 0
      out_offset = args[:out_offset] || 0
      if(!@relations.nil?)
        return
      end

      input_set = args[:input]

      @relations = Set.new
      if(input_set.root?)
        @relations = input_set.server.relations(out_offset, out_limit)
      else
        if(args[:position] == "domain")
          entities = input_set.each_domain
        else
          entities = input_set.each_item
        end
        entities.select!{|e| !e.is_a?(Xpair::Literal)}
        @limit = args[:limit] || entities.size
        @relations = Set.new input_set.server.begin_nav_query.find_relations(entities[0..@limit], out_offset, out_limit)        
      end


      finish_time = Time.now

      puts "FindRelations: " <<(finish_time - start_time).to_s
    end
    
    def eval_item(item)
      @relations
    end

    def v_expression
      "Relations()"
    end
    
    def expression
      limit = @args[:limit] || @args[:input].each_item.size
      "#{@args[:input].id}.relations(limit: #{limit.to_s})"
    end
  end
  
  def relations(args = {})
    args[:direction] = "backward"

    execute_exploration_operation(FindRelations, args)
  end

  def v_relations(args = {})
    args[:direction] = "backward"

    execute_visualization_operation(FindRelations, args)
  end
  
  def forward_relations(args = {})
      execute_operation(FindRelations, args)
  end
  
end