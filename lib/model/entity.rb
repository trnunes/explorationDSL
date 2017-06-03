
class Entity < Item

  def relations
    relations = {}
    servers.each do |server|
      query = server.begin_nav_query do |q|        
        q.on(Entity.new(params[:id]))
        q.find_relations
      end    
      results_hash = query.execute

      results_hash.each do |relation, values|
        if relations.has_key?(relation)
          relations[relation] += values
        else
          relations[relation] = values
        end
      end
    end
    relations
  end
    
  def entity?
    true
  end
    
  
  def expression
    "Entity.new(\"" + @id + "\")"
  end
  
  def to_json(*a)
    {
      "json_class"   => self.class.name,
      "data"         => {"id" => @id}
    }.to_json(*a)
  end
  def to_s
    self.id
  end
  def self.json_create(json_hash)
    new(json_hash["data"]["id"])
  end
  def inspect
    to_s
  end
end
