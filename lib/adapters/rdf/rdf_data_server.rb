require 'rdf'
require 'sparql/client'

class RDFDataServer < DataServer
  include RDFNavigational
  
  ACCEPT_PATH_QUERY = true
  
  ###
  ### Inform whether the RDF server can handle property path queries
  ###  
  ACCEPT_PATH_CLAUSE = false

  attr_accessor :graph, :items_limit, :content_type, :api_key, :cache, :filter_intepreter


  def initialize(options = {})
    setup options    
  end
  
  def setup(options)
    @graph = SPARQL::Client.new options[:graph], options
    @content_type = options[:content_type] || "application/sparql-results+xml"
    @api_key = options[:api_key]
    @cache_max_size = options[:cache_limit] || 20000
    @items_limit = options[:items_limit] || 300
    @results_limit = options[:limit] || 5000
    
    #Default Namespaces
    Xplain::Namespace.new("owl", "http://www.w3.org/2002/07/owl#")
    Xplain::Namespace.new("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
    Xplain::Namespace.new("xsd", "http://www.w3.org/2001/XMLSchema#")
    Xplain::Namespace.new("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    Xplain::Namespace.new("dcterms", "http://purl.org/dc/terms/")
    Xplain::Namespace.new("foaf", "http://xmlns.com/foaf/0.1/")
    Xplain::Namespace.new("rss", "http://purl.org/rss/1.0/")
  end
  
  def size
    @graph.count
  end
  
  def path_string(relations)
    relations.map{|r| "<" << Xplain::Namespace.expand_uri(r.to_s) << ">"}.join("/")
    
  end
  
  def sample_type(items, relation_uri = "", inverse = false)
    types = Xplain::Visualization.types
    types.delete("http://www.w3.org/2000/01/rdf-schema#Resource")
    
    retrieved_types = []
    if(types.size > 0 && !items[0].is_a?(Xplain::Literal))
      types_values_clause = "VALUES ?t {#{types.map{|t| "<" + Xplain::Namespace.expand_uri(t) + ">"}.join(" ")}}"
      items_values_clause = "VALUES ?s {#{items[0..5].map{|i| "<" + Xplain::Namespace.expand_uri(i.id) + ">"}.join(" ")}}"
      spo_clause =  ""
      if !relation_uri.to_s.empty?
        if inverse
          spo_clause = "?o #{relation_uri} ?s."
        else
          spo_clause = "?s #{relation_uri} ?o."
        end
      end
      query = "SELECT distinct ?t WHERE{#{items_values_clause}. #{types_values_clause}. #{spo_clause} ?o <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t}"
      execute(query, content_type: content_type).each do |s|
        retrieved_types << Xplain::Namespace.expand_uri(s[:t].to_s)
      end
    end
    
    types_with_vis_properties = (retrieved_types & types)
    types_with_vis_properties.empty? ? Xplain::Type.new("rdfs:Resource") : Xplain::Type.new(types_with_vis_properties.first)
  end

  def match_all(keyword_pattern, restriction_nodes=[], offset = 0, limit = 0)
    retrieved_items = []
    label_relations = Xplain::Visualization.label_relations_for("rdfs:Resource")    
    values_p = values_clause("?p", label_relations.map{|id| "<#{id}>"})
    
    filter_clause = "regex(str(?ls), \".*#{keyword_pattern.join('.*')}.*\")" 
    query = "SELECT distinct ?s ?ls WHERE{
      #{values_clause("?s", restriction_nodes.map{|n|n.item})} 
      #{values_p} {?s ?p ?ls}. FILTER(#{filter_clause}).}"
    
    execute(query, {content_type: content_type, offset: offset, limit: limit}).each do |s|
      puts s.inspect
      item = Xplain::Entity.new(Xplain::Namespace.colapse_uri(s[:s].to_s))
      item.add_server(self)
      retrieved_items << item
    end
    
    retrieved_items
  end
  
    
  def each_item(&block)
    items = []
    query = @graph.query("SELECT ?s WHERE{?s ?p ?o.}")
    query.each_solution do |solution|
      item = Xplain::Entity.new(solution[:s].to_s)
      item.add_server(self)  
      items << item      
      block.call(item) if !block.nil?
    end       
    items
  end
     
  def execute(query, options = {})
    solutions = []

    offset = options[:offset] || 0
    limit = options[:limit] || 0
    rs = [0]

    limited_query = query #+ "limit #{@limit} offset #{offset}"

    if(limit > 0)
      limited_query << "limit #{limit} offset #{offset}"
    end

    puts limited_query.to_s
    rs = @graph.query("PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> " << limited_query, options)      
    rs_a = rs.to_a
    
    solutions += rs_a
    solutions
  end
  
  ###
  ### return: the nodes grouped by the image items of the relation. 
  ### The relation returned is the inverse of _relation arg 
  ###
  def group_by(nodes, relation)
    
    if nodes.empty?
      return []
    end
    if relation.nil?
      raise MissingRelationException
    end
    result_hash = {}
    images_hash = restricted_image(relation: relation, restriction: nodes)
    inverse_relation = relation.reverse
    images_hash.each do |key, values|
      values.each do |value|
        if !result_hash.has_key? value
          result_hash[value] = {}
          result_hash[value][inverse_relation] = 
            if key.is_a? Xplain::Literal
              []
            else
              Set.new
            end
        end        
        result_hash[value][inverse_relation] << key
      end
    end
    result_hash
  end
  
  def aggregate(nodes, relation, aggregate_function, restriction = [])
    if nodes.empty?
      return []
    end
    if relation.nil?
      raise MissingRelationException
    end
    items = nodes.map{|node| node.item}
    values_stmt = "VALUES ?s {#{items.map{|item| "<" + Xplain::Namespace.expand_uri(item.id) + ">"}.join(" ")}}"
    query_stmt = "SELECT ?s (#{aggregate_function}(?o) as ?o) where{#{values_stmt} #{path_clause(relation)} #{values_clause("?o", restriction)} #{path_clause_as_subselect(relation, values_stmt, "?s", limit, offset)}. }"
    query_stmt << " GROUP BY ?s"
    get_results(query_stmt, relation)
  end
  
  def sum(items, relation, restriction = [])
    aggregate(items, relation, "sum", restriction)
  end
  
  def count(items, relation, restriction = [])
    aggregate(items, relation, "count", restriction)
  end

  def avg(items, relation, restriction = [])
    aggregate(items, relation, "avg", restriction)
  end
  
  def has_filter_intepreter?
    !@filter_intepreter.nil?
  end
  
  def filter(input_items, filter_expr)
    if input_items.empty?
      return []
    end
    dataset_filter(input_items, filter_expr)
  end
  
  def dataset_filter(input_items = [], filter_expr)
    interpreter = SPARQLFilterInterpreter.new()
    parsed_query = interpreter.parse(filter_expr)
    query = "SELECT ?s ?ls where{"
    query << values_clause("?s", input_items)
    query << mount_label_clause("?s", input_items)
    query << parsed_query + "}"
    get_filter_results(query)
  end
  
  def validate_filters(filter_expr)
    interpreter = SPARQLFilterInterpreter.new()
    invalid_filters = interpreter.validate_filters(filter_expr)
    return invalid_filters
  end
  
  def can_filter?(filter_expr)
    interpreter = SPARQLFilterInterpreter.new()
    interpreter.can_filter? filter_expr
  end
  
  def can_aggregate?(items, aggregation_function)
    true
  end
end