load "./model/item.rb"
require 'json'
class Relation < Item
  attr_accessor :first_item
  attr_accessor :second_item
  
  def [](index)
    [@first_item, @second_item][index]
  end
  
  def relation?
    true
  end
  
  def expression
    "Relation.new(#{first_item.expression}, #{second_item.expression})"
  end
  def []=(index, element)
    case(index)
    when 0
      @first_item = element
    when 1
      @second_item = element
    else
      raise IndexError
    end
  end
  
  def swap!
    @first_item, @second_item = @second_item, @first_item
  end
  
  def swap
    new(@second_item, @first_item)
  end
  
  def initialize(first_item, second_item)
    @first_item = first_item
    @second_item = second_item
  end
  
  def to_s
    "(" + @first_item.to_s + ", " + @second_item.to_s + ")"
  end
  
  def id
    to_s
  end
  
  def hash
    @first_item.hash ^ @second_item.hash
  end
  
  def eql?(relation)
    self.class.equal?(relation.class) && relation.first_item == @first_item && relation.second_item == @second_item
  end
  alias == eql?
  
  def inspect
    to_s
  end
  
  def to_json(*a)
    {
      "json_class"   => self.class.name,
      "data"         => {"first_item" => @first_item.to_json, "second_item" => @second_item.to_json }
    }.to_json(*a)
  end
  
  def self.json_create(hash)

    first_item_hash = JSON.parse(hash["data"]["first_item"])
    
    second_item_hash = JSON.parse(hash["data"]["second_item"])
    
    new(eval(first_item_hash["json_class"]).json_create(first_item_hash), eval(second_item_hash["json_class"]).json_create(second_item_hash))
  end
end
