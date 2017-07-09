module Explorable
  class FindRelations < Explorable::Operation   
    
    def delayed_result?
      true
    end
    
    def prepare(args)
      start_time = Time.now
      @result_set = Set.new
      if(!@relations.nil?)
        return
      end

      input_set = args[:input]
      if(args[:position] == "domain")
        entities = input_set.each_domain
      else
        entities = input_set.each_item
      end
      entities.select!{|e| !e.is_a?(Xpair::Literal)}
      @limit = args[:limit] || entities.size

      @relations = Set.new
      @relations = Set.new input_set.server.begin_nav_query.find_relations(entities[0..@limit])
      # binding.pry

      finish_time = Time.now

      puts "FindRelations: " <<(finish_time - start_time).to_s
    end
    
    def eval_item(item)
      @relations
    end
     
    # def eval()
    #   start_time = Time.now
    #
    #   input_set = @args[:input]
    #   entities = input_set.each_entity.to_a
    #   limit = @args[:limit]
    #   limit ||= entities.size
    #
    #   keep_structure = @args[:keep_structure].nil? ? false : @args[:keep_structure]
    #
    #   mappings = {}
    #   results = input_set.server.begin_nav_query.find_forward_relations(entities[0..limit])
    #
    #   results.each do |item, relations_hash|
    #     mappings[item] = {}
    #     relations_hash.each do |relation, values|
    #       mappings[item][relation] = {}
    #     end
    #   end
    #   if(@args[:direction] == 'backward')
    #     results = input_set.server.begin_nav_query.find_backward_relations(entities[0..limit])
    #
    #     results.each do |item, relations_hash|
    #       mappings[item] ||= {}
    #       relations_hash.each do |relation, values|
    #         r = Relation.new(relation.id)
    #         r.servers = relation.servers
    #         r.inverse = true
    #         r.text += " of"
    #         mappings[item][r] = {}
    #       end
    #     end
    #   end
    #   finish_time = Time.now
    #
    #   puts "FindRelations: " <<(finish_time - start_time).to_s
    #   return mappings
    # end

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
    # binding.pry
    execute_exploration_operation(FindRelations, args)
  end

  def v_relations(args = {})
    args[:direction] = "backward"
    # binding.pry
    execute_visualization_operation(FindRelations, args)
  end
  
  def forward_relations(args = {})
      execute_operation(FindRelations, args)
  end
  
end