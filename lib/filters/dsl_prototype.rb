require 'pry'
class Relation
  attr_accessor :id
  def initialize(id, inverse = false)
    @id = id
    @inverse = inverse
  end
  def to_s
    @id
  end
  def inspect
    to_s
  end
end

class PathRelation
  attr_accessor :relations
  def initialize(relations)
    @relations = relations
  end
  def to_s
    @relations.join("/")
  end
  def inspect
    to_s
  end
  
end

class Entity
  attr_accessor :id
  def initialize(id)
    @id = id
  end
  
  def to_s
    "Entity: " + @id
  end
  
  def inspect
    to_s
  end
end

class Literal
  attr_accessor :value, :type
  def initialize(value, type = "")
    @value = value
    @type = type
  end
  
  def to_s
    "Literal: " + @value.to_s
  end
  
  def inspect
    to_s
  end
end

module ModelFactory
  attr_accessor :values, :fvalue, :frelation
  
  def relation(*relations)
    
    relations.map!{|r| r.is_a?(Hash)? Relation.new(r.values.first, true) : Relation.new(r)}
    
    if relations.size > 1
      @frelation = PathRelation.new(relations)
    else
      @frelation = relations.first
    end
    
  end
  
  def entity(entity_id)
    @fvalue = Entity.new(entity_id)
  end
  
  def literal(l_value)    
    @values = [l_value.is_a?(Hash)? Literal.new(l_value.values.first, l_value.keys.first) : Literal.new(l_value)]
  end
  
  def entities(*entities)
    @values = entities.map!{|id| Entity.new(id)}
  end
  
  def literals(*literals)    
    @values = literals.map!{|l| l.is_a?(Hash)? Literal.new(l.values.first, l.keys.first) : Literal.new(l)}
  end
end

class SPARQLInterpreter
  
  def initialize()
    @relations_index = 1
  end
  
  def convert_literal(literal)
    "\"#{literal.to_s}\"^^#{get_literal_type(literal)}"
  end
  
  def get_literal_type(literal)
    datatype = literal.datatype
    case datatype
      when "http://www.w3.org/2001/XMLSchema#nonPositiveInteger"
        "xsd:integer"
      when "http://www.w3.org/2001/XMLSchema#negativeInteger"
        "xsd:integer"
      when "http://www.w3.org/2001/XMLSchema#long"
        "xsd:integer"
      when "http://www.w3.org/2001/XMLSchema#int"
        "xsd:integer"
      when "http://www.w3.org/2001/XMLSchema#short"
        "xsd:integer"
      when "http://www.w3.org/2001/XMLSchema#double"
        "xsd:double"
      when "http://www.w3.org/2001/XMLSchema#float"
        "xsd:float" 
      when "http://www.w3.org/2001/XMLSchema#date"
        "xsd:date"
      when "http://www.w3.org/2001/XMLSchema#datetime"
        "xsd:datetime"
      else
        "xsd:string"
    end
  end
  
  def convert_entity(entity)
    "<#{entity.id}>"
  end
  
  def parse_item(item)
    if(item.is_a? Literal)
      convert_literal(item)
    else
      convert_entity(item)
    end        
  end
  
  def filter(var, operator, value)
    if(value.is_a? Literal)
      "#{get_literal_type(value)}(#{var}) #{operator} #{convert_literal(value)}"
    else
      "#{var} #{operator} #{convert_entity(value)}"
    end    
  end
  
  def interpret(f)
    filters = generate_filters(f.filters.first)
    query = "SELECT ?s where{"
    query << filters.keys.join(". ")
    filters_clauses = filters.values.flatten
    if(!filters_clauses.empty?)
      query << " FILTER(" + filters.values.flatten.join(" && ") + ")"
    end
    
    query << "}"
    query
  end
      
  def generate_where_hash(relation, operator, value)
    hash = {"subject"=>[]}

    where = "?s <" + relation.to_s + "> ?o"
    if relation
      hash[where] ||= []
      hash[where] << filter("?o", operator, value)
    else
      hash["subject"] << value
    end
    hash
  end
  
  def generate_filters(f)
    # binding.pry
    hash = {}
    filter_clause = 
    if f.class == Refine::Equals
      
      generate_where_hash(f.frelation, "=", f.fvalue)
    elsif f.class == Refine::Contains
      if(f.respond_to? :frelation)
        where_clause = "?s <#{f.frelation}> ?o#{@relations_index+=1}"
       
        where_clause << " VALUES ?o#{@relations_index}{" + f.values.map{|item| parse_item(item)}.join(" ") + "}"
      else
        hash["subject"] << f.values
      end 
      {where_clause => []}
      
    elsif f.class == Refine::EqualsOne      

     if(f.respond_to? :frelation)
       where_clause = "?s <#{f.frelation}> ?o#{@relations_index+=1}"
       
       where_clause << " VALUES ?o#{@relations_index}{" + f.values.map{|item| parse_item(item)}.join(" ") + "}"
     else
       hash["subject"] << f.fvalue
     end 
     {where_clause => []}
    elsif f.class ==  Refine::Lt
      generate_where_hash(f.frelation, "<", f.fvalue)
    elsif f.class == Refine::LtEql
      generate_where_hash(f.frelation, "<=", f.fvalue)
    elsif f.class == Refine::Grt
      generate_where_hash(f.frelation, ">", f.fvalue)
    elsif f.class == Refine::GrtEql
      generate_where_hash(f.frelation, ">=", f.fvalue)
    elsif f.class == Refine::AndFilter
      hash = {}
      where_clauses = []
      filters = []
      f.filters.each do |af|
        hash.merge!(generate_filters(af)){|where, filters1, filters2| filters1 + filters2}
      end
      hash.delete("subject")
      
      hash.each do |where, fclauses|

        where_copy = where.gsub("?o","?o#{@relations_index+=1}")        
        filters << ("(" + fclauses.map{|c| c.gsub("?o", "?o#{@relations_index}")}.join(" && ") + ")")
        where_clauses << where_copy

      end
      # binding.pry
      where_clause = where_clauses.join(". ") << " Filter(" + filters.join(" && ") + ")"
      {where_clause => []}    
      
    elsif f.class == Refine::OrFilter
      hash = {}
      where_clauses = []
      # binding.pry
      filter_clause = ""
      f.filters.each do |af|
        hash.merge!(generate_filters(af)){|where, filters1, filters2| filters1 + filters2}
      end
      hash.delete("subject")
      
      hash.each do |where, fclauses|

        where_copy = where.gsub("?o","?o#{@relations_index+=1}")
        filter_clause = "(" + fclauses.map{|c| c.gsub("?o", "?o#{@relations_index}")}.join(" || ") + ")"
        where_clauses << "{" + where_copy + ". FILTER(#{filter_clause})}"
      end

      where_clause = where_clauses.join(" UNION ") 
      {where_clause => []}    
    elsif f.class == Refine::Not
      "not implemented"        
    end
    filter_clause
  end
end


module Refine
  attr_accessor :filters
  
  class Equals
    include ModelFactory
  end
  
  class Lt
    include ModelFactory
  end
  
  class LtEql
    include ModelFactory
  end
  
  class Grt
    include ModelFactory
  end

  class GrtEql
    include ModelFactory
  end
  
  class Not
    include ModelFactory
  end
   
  class EqualsOne
    include ModelFactory
  end
  
  class Contains
    include ModelFactory
  end
  
  class AndFilter
    include Refine
    attr_accessor :filters
    def initialize
      @filters = []
    end    
  end

  class OrFilter
    include Refine
    attr_accessor :filters
    def initialize
      @filters = []
    end
  end
  
  def And(&block)
    i = AndFilter.new
    i.instance_eval &block
    @filters ||= []
    @filters << i
    
    i
  end

  def Or(&block)
    i = OrFilter.new
    i.instance_eval &block
    @filters ||= []
    @filters << i
    
    i
  end
  
  def equals_one(&block)
    i = EqualsOne.new
    
    i.instance_eval &block
    @filters ||=[]
    @filters << i
    i
  end
  
  
  def equals(&block)
    i = Equals.new
    
    i.instance_eval &block
    @filters ||= []
    @filters << i
    i
  end
  
  def contains(&block)
    i = Contains.new
    
    i.instance_eval &block
    @filters ||=[]
    @filters << i
    i
    
  end
  
  def match(&block)
    
  end

  def refine(&block)
    f = self.instance_eval &block
    self
  end
end

class Xset
  include Refine  
end

r = Xset.new.refine do
  equals do
    relation "rtest", "rtest2"
    entity "s"
  end
end
i = SPARQLInterpreter.new
puts i.interpret r


r = Xset.new.refine do
  And do
    equals do 
      relation "rtest", "rtest2"
      entity "s"
    end  
    equals do
      relation "rtest", "rtest2"
      entity "t"
    end
    
  end
end
i = SPARQLInterpreter.new
puts i.interpret r

r = Xset.new.refine do
  And do
    equals do 
      relation "rtest", "rtest2"
      entity "s"
    end  
    Or do
      equals do 
        relation "rtest", "rtest2"
        entity "s"
      end  
      equals do
        relation "rtest", "rtest2"
        entity "t"
      end
    end
  end
end
i = SPARQLInterpreter.new
puts i.interpret r

r = Xset.new.refine{And{equals{relation "r1", "r2"; entity "s"}; equals{relation "r1", "r2"; entity "t"}}}
i = SPARQLInterpreter.new
puts i.interpret r

r = Xset.new.refine do
  Or do
    equals do 
      relation "rtest1"
      entity "s"
    end  
    equals do
      relation "rtest2"
      entity "t"
    end    
  end
end

i = SPARQLInterpreter.new
puts i.interpret r

r = Xset.new.refine do
  equals_one do
    relation "rtest", inverse: "rtest2"
    entities "s", "t", "z"
  end
end

i = SPARQLInterpreter.new
puts i.interpret r
