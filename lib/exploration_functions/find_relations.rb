module Explorable
  class FindRelations < Explorable::Operation   
    def eval()
      start_time = Time.now

      input_set = @args[:input]
      entities = input_set.each_entity.to_a
      limit = @args[:limit]
      limit ||= entities.size

      keep_structure = @args[:keep_structure].nil? ? false : @args[:keep_structure]

      mappings = {}
      results = input_set.server.begin_nav_query.find_relations(entities[0..limit])

      results.each do |item|

        mappings[item] = {}

      end
      finish_time = Time.now

      puts "FindRelations: " <<(finish_time - start_time).to_s
      return mappings
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
    
    def expression
      "relations(#{@args[:input].id})"
    end
  end
  
  def relations(args = {})
    args[:direction] = "backward"
    execute_operation(FindRelations, args)
  end
  
  def forward_relations(args = {})
      execute_operation(FindRelations, args)
  end
  
end