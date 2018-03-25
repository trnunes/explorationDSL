class SPARQLFilterInterpreter
  include SPARQLHelper
  @@accepted_filters =   [And, Or, Equals, Contains, EqualsOne, LessThan, LessThanEqual, GreaterThan, GreaterThanEqual]
  
  def accept_path_clause?
    false
  end
  
  def initialize()
    @relations_index = 1
  end
  
  def filter(var, operator, value)
    if(value.is_a? Xplain::Literal)
      if !value.datatype.nil?
        "#{var} #{operator} #{parse_item(value)}"
      else
        "#{var} #{operator} \"#{value.value.to_s}\""
      end
      
    else
      "#{var} #{operator} #{parse_item(value)}"
    end    
  end
  
  def validate_filters(filter_expr, invalid_filters = [])
    invalid_filters << filter_expr if !@@accepted_filters.include?(filter_expr.class)
    if filter_expr.respond_to? :filters
      filter_expr.filters.each{|filter| validate_filters(filter, invalid_filters)}
    end
    return invalid_filters
  end
  
  def can_filter?(filter_expr)

    if filter_expr.respond_to? :filters
      return filter_expr.filters.inject(false){|boolean, filter| boolean || can_filter?(filter)}
    end

    return @@accepted_filters.include? filter_expr.class
  end
  
  
  def parse(f)

    filters = generate_filters(f)

    query = ""
    query << filters.keys.join(". ")
    filters_clauses = filters.values.flatten
    if(!filters_clauses.empty?)
      query << " FILTER(" + filters.values.flatten.join(" && ") + ")"
    end
    
    query
  end
      
  def generate_where_hash(relation, operator, value)
    hash = {}
    where = path_clause(relation)
    if relation
      hash[where] ||= []
      hash[where] << filter("?o", operator, value)
    else
#.*subject.*
    end
    hash
  end
  
  def generate_filters(f)

    hash = {}
    filter_clause = 
    if f.class == Equals
      
      generate_where_hash(f.frelation, "=", f.values.first)
    elsif f.class == Contains
      if(f.respond_to? :frelation)
        where_clause = "?s <#{f.frelation}> ?o#{@relations_index+=1}"
       
        where_clause << " VALUES ?o#{@relations_index}{" + f.values.map{|item| parse_item(item)}.join(" ") + "}"
      else
#.*subject.*
      end 
      {where_clause => []}
      
    elsif f.class == EqualsOne

     if(f.respond_to? :frelation)
       where_clause = "?s <#{f.frelation}> ?o#{@relations_index+=1}"
       
       where_clause << " VALUES ?o#{@relations_index}{" + f.values.map{|item| parse_item(item)}.join(" ") + "}"
     else
#.*subject.*
     end 
     {where_clause => []}
    elsif f.class ==  LessThan
      generate_where_hash(f.frelation, "<", f.values.first)
    elsif f.class == LessThanEqual
      generate_where_hash(f.frelation, "<=", f.values.first)
    elsif f.class == GreaterThan
      generate_where_hash(f.frelation, ">", f.values.first)
    elsif f.class == GreaterThanEqual
      generate_where_hash(f.frelation, ">=", f.values.first)
    elsif f.class == And
      hash = {}
      where_clauses = []
      filters = []
      f.filters.each do |af|
        hash = generate_filters(af)
        hash.each do |where, where_filters|
          where_clauses << where.gsub("?o","?o#{@relations_index+=1}")
          filters << ("(" + where_filters.map{|c| c.gsub("?o", "?o#{@relations_index}")}.join(" && ") + ")")
        end

      end
      where_clause = where_clauses.join(". ") << " Filter(" + filters.join(" && ") + ")"
      {where_clause => []}    
      
    elsif f.class == Or
      hash = {}
      where_clauses = []

      filter_clause = ""
      f.filters.each do |af|
        hash.merge!(generate_filters(af)){|where, filters1, filters2| filters1 + filters2}
      end
#.*subject.*
      
      hash.each do |where, fclauses|

        where_copy = where.gsub("?o","?o#{@relations_index+=1}")
        filter_clause = "(" + fclauses.map{|c| c.gsub("?o", "?o#{@relations_index}")}.join(" || ") + ")"
        where_clauses << "{" + where_copy + ". FILTER(#{filter_clause})}"
      end

      where_clause = where_clauses.join(" UNION ") 
      {where_clause => []}    
    elsif f.class == Not
      "not implemented"        
    end
    filter_clause
  end
end
