load "./model/item.rb"
class Entity < Item
  attr_accessor :id
  def initialize(id)
    @id = id
  end
  def to_s
    @id.to_s
  end
  
  def entity?
    true
  end
  
  def hash
    @id.hash
  end
  
  def eql?(entity)
    self.class.equal?(entity.class) && @id == entity.id
  end
  
  def expression
    "Entity.new(\"" + id + "\")"
  end
  
  def to_json(*a)
    {
      "json_class"   => self.class.name,
      "data"         => {"id" => @id}
    }.to_json(*a)
  end
  
  def self.json_create(json_hash)
    new(json_hash["data"]["id"])
  end
  alias == eql?
end
