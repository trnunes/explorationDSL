module SPARQLQuery
  def self.convert_literal(literal)
    if literal.has_datatype? && !literal.datatype.downcase.include?("string")
      return "\"" << literal.value << "\"^^<#{literal.datatype}>"
    elsif literal.value.class == Fixnum || literal.value.class == Float
      return literal.value.to_s
    else
      begin
        return Integer(literal.value).to_s
      rescue ArgumentError => e
        begin
          return Float(literal.value).to_s
        rescue ArgumentError => e
          return "\"" +  literal.value.to_s + "\""
        end
      end
    end
  end
  
  # def self.get_literal_type(literal)
  #   type = ""
  #   if(literal.datatype && !literal.datatype.downcase.include?("string"))
  #     type = Xpair::Namespace.colapse_uri(literal.datatype)
  #   elsif literal.value.class == Fixnum
  #     type = "xsd:integer"
  #   elsif literal.value.class == Float
  #     type = "xsd:float"
  #   else
  #     type = "xsd:string"
  #   end
  #   type
  # end
  
  def self.get_literal_type(literal)
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
  
end
