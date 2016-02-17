require 'forwardable'
require 'mixins/explorable'
require 'model/item.rb'
require 'json'
class Xset < Item
  extend Forwardable
  include Explorable

  
  attr_accessor :id
  attr_accessor :elements
  
  def_delegators :@elements, :each, :map, :map!, :select, :select!, :size, :<<, :[], :push, :delete, :partition, :uniq, :uniq!, :first, :last, :+, :empty?, :include?
  
  def initialize(id, elements = [])
    @elements = elements
    @id = id
  end
  
  def set?
    true
  end
  
  def expression
    @expression ||= "Xset.load(\""+id+"\")"
    @expression
  end
  
  def concat(array)
    if(array.is_a?(Xset))
      array = array.elements
    end
    @elements = @elements.concat(array)    
  end
  
  def eql?(xset)
    if(self.class.equal?(xset.class) && @id == xset.id && elem_eql?(xset))
      return true
    end
    return false
  end
  alias eql? ==
  
  def to_s
    desc = ""
    each{|p| desc << p.to_s + "\n" }
    desc
  end
  
  def elem_eql?(xset)
    @elements == xset.elements
  end
  
  def to_json(*a)
    {
      "json_class"   => self.class.name,
      "data"         => {"elements" => @elements.map{|element| element.to_json}, "expression" => expression}
    }.to_json(*a)
  end
  
  def self.json_create(hash)
    elements_hash = hash["data"]["elements"]
    elements = elements_hash.map do |element|  
      parsed_element = JSON.parse(element)
      eval(parsed_element["json_class"]).json_create(parsed_element)
    end
    
    new_instance = new(hash["data"]["id"], elements)
    new_instance.expression = hash["data"]["expression"]
    new_instance
  end
   
  def self.load(id)
    path = "./datasets/" + id.to_s + ".json"
    json_string = File.read(path)
    json_hash = JSON.parse(json_string)
    json_create(json_hash)
  end
  
  
  def save
    File.open("./datasets/"+self.id.to_s+".json", 'w'){|f| f.write(self.to_json)}
  end
end
