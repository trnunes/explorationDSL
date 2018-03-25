require 'rdf'
require 'sparql/client'

class RDFDataServer < DataServer
  include RDFNavigational
  attr_accessor :graph, :namespace_map, :label_property, :items_limit, :content_type, :api_key, :cache, :filter_intepreter


  def initialize(options = {})
    @graph = SPARQL::Client.new options[:graph], options
    @label_property = options[:label_property]
    @namespace_map = {}
    @content_type = options[:content_type]
    @content_type ||= "application/sparql-results+xml"
    @api_key = options[:api_key]
    @cache_max_size = options[:cache_limit]
    @cache_max_size ||= 20000
    @cache = RDFCache.new(@cache_max_size)
  end  
  
  def size
    @graph.count
  end
  
  def accept_path_query?
    true
  end
  
  def path_string(relations)
    relations.map{|r| "<" << Xplain::Namespace.expand_uri(r.to_s) << ">"}.join("/")
    
  end
  
  def sample_type(relation_uri, items, inverse = false)
    types = Xplain::Visualization.types
    types.delete("http://www.w3.org/2000/01/rdf-schema#Resource")
    retrieved_types = []
    if(types.size > 0 && !items[0].is_a?(Xplain::Literal))
      types_values_clause = "VALUES ?t {#{types.map{|t| "<" + Xplain::Namespace.expand_uri(t) + ">"}.join(" ")}}"
      items_values_clause = "VALUES ?s {#{items[0..5].map{|i| "<" + Xplain::Namespace.expand_uri(i.id) + ">"}.join(" ")}}"
      if inverse
        query = "SELECT distinct ?t WHERE{#{items_values_clause}. #{types_values_clause}. ?o #{relation_uri} ?s. ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t}"
      else
        query = "SELECT distinct ?t WHERE{#{items_values_clause}. #{types_values_clause}. ?s #{relation_uri} ?o. ?o <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t}"
      end
      
      execute(query, content_type: content_type).each do |s|
        retrieved_types << Xplain::Entity.new(Xplain::Namespace.expand_uri(s[:t].to_s))
      end
    end
    types_with_vis_properties = (retrieved_types & types)
    types_with_vis_properties.empty? ? Xplain::Entity.new("rdfs:Resource") : types_with_vis_properties.first
  end
  
  def types(limit = 0, offset = 0)
    
    query = "SELECT DISTINCT ?class WHERE { ?s a ?class.}"
    classes = []
    execute(query, {content_type: content_type, offset: offset, limit: limit}).each do |s|
      type = Type.new(Xplain::Namespace.colapse_uri(s[:class].to_s))
      # type.text = s[:label].to_s if !s[:label].to_s.empty?
      type.add_server(self)
      classes << type
    end
    classes
  end
  
  def instances(type, offset=0, limit=0)
    query = "SELECT DISTINCT ?s  WHERE { ?s a <#{Xplain::Namespace.expand_uri(type.id)}>.}"
    
    instances = []
    execute(query, {content_type: content_type, offset: offset, limit: limit}).each do |s|
      item = Xplain::Entity.new(Xplain::Namespace.colapse_uri(s[:s].to_s))
      # item.text = s[:label].to_s if !s[:label].to_s.empty?
      item.add_server self
      instances << item
    end
    instances
  end
  
  def relations(offset = 0, limit = 0)
    query = "SELECT DISTINCT ?relation WHERE { ?s ?relation ?o.}"
        
    classes = []
    execute(query, {content_type: content_type, offset: offset, limit: limit}).each do |s|
      relation = Xplain::SchemaRelation.new(Xplain::Namespace.colapse_uri(s[:relation].to_s), false, self)
      # relation.text = s[:label].to_s if !s[:label].to_s.empty?
      relation.server = self
      classes << relation
    end
    classes    
  end
  
  def search(keyword_pattern, offset = 0, limit = 0)
    filters = []
    unions = []
    items = []
    keyword_pattern.each do |pattern|
      filters << "(regex(str(?o), \"#{pattern}\"))"
    end

    label_clause = SPARQLQuery.label_where_clause("?s", "rdfs:Resource")
    query = "SELECT distinct ?s ?lo WHERE{?s ?p ?o. #{label_clause}  FILTER(#{filters.join(" && ")}) } "
    
    execute(query, {content_type: content_type, offset: offset, limit: limit}).each do |s|
      item = Xplain::Entity.new(Xplain::Namespace.colapse_uri(s[:s].to_s))
      item.add_server(self)
      items << item
    end
    items
  end
  
  def match_all(keyword_pattern, offset = 0, limit = 0)
    blaze_graph_search(keyword_pattern, offset, limit)
  end
  
  def blaze_graph_search(keyword_pattern, offset = 0, limit = 0)
    filters = []
    unions = []
    items = []
    label_clause = SPARQLQuery.label_where_clause("?s", Xplain::Visualization.label_relations_for("rdfs:Resource"))
    label_clause = " OPTIONAL " + label_clause if !label_clause.empty?
    query = "select ?s ?p ?o ?ls where {?o <http://www.bigdata.com/rdf/search#search> \" #{keyword_pattern.join(" ")}\". ?o <http://www.bigdata.com/rdf/search#matchAllTerms> \"true\" . ?s ?p ?o . #{label_clause}}"


    execute(query,{content_type: content_type, offset: offset, limit: limit}).each do |s|
      item = Xplain::Entity.new(Xplain::Namespace.colapse_uri(s[:s].to_s),  "rdfs:Resource")
      item.text = s[:ls].to_s
      item.add_server(self)
      items << item
    end
    items.sort{|i1, i2| i1.text <=> i2.text}
  end
  
  

  def begin_filter(options = {}, &block)
    f = SPARQLQuery::SPARQLFilter::ANDFilter.new(self)
    if(options[:limit].to_i > 0)
      f.limit = options[:limit].to_i
      f.offset = options[:offset].to_i
    end
    
    if block_given?
      yield(f)
      f
    else
      f
    end
        
  end
  
  def find_relations(entity)
    QueryBuilder.new(self).find_relations(entity)
  end
  
  def all_relations(&block)
    relations = []
    query = @graph.query("SELECT distinct ?p ?label WHERE{?s ?p ?o. OPTIONAL{?p <#{Xplain::Namespace.expand_uri("rdfs:label")}> ?label}")
    query.each_solution do |solution|
      relation = Xplain::SchemaRelation.new(Xplain::Namespace.colapse_uri(solution[:p].to_s))
      relation.text = solution[:label].to_s
      relation.server = self;
      relations << relation
      block.call(relation) if !block.nil?
    end       
    relations
  end
  
  def each_item(&block)
    items = []
    query = @graph.query("SELECT ?s WHERE{?s ?p ?o.}")
    query.each_solution do |solution|
      item = Xplain::Entity.new(solution[:s].to_s)
      item.add_server(self)  
      items << item
      # 
      block.call(item) if !block.nil?
    end       
    items
  end
    
  def image(relation, restriction=[], offset = 0, limit = -1, crossed=false, &block)
    items = []
    values_stmt = ""
    if relation.inverse? && !crossed
      return domain(relation, restriction, offset, limit, true, &block)
    end
    
    if(!restriction.empty?)
      values_stmt = "VALUES ?s {#{restriction.map{|item| "<" + Xplain::Namespace.expand_uri(item.id) + ">"}.join(" ")}}"
    end
    
    query_stmt = "SELECT distinct ?o where{#{values_stmt} ?s <#{Xplain::Namespace.expand_uri(relation.id)}> ?o}"
    query_stmt = insert_order_by_subject(query_stmt)
    if limit > 0
      query_stmt << " OFFSET #{offset} LIMIT #{limit}"
    end
    puts query_stmt
    get_results(query_stmt, relation)
  end

  def domain(relation, restriction=[], offset=0, limit=-1, crossed=false, &block)
    items = []
    values_stmt = ""
    if relation.inverse? && !crossed
      return image(relation, restriction, offset, limit, true, &block) 
    end
    
    if(!restriction.empty?)
      values_stmt = "VALUES ?o {#{restriction.map{|item| "<" + Xplain::Namespace.expand_uri(item.id) + ">"}.join(" ")}}"
    end
    query_stmt = "SELECT ?s ?o where{#{values_stmt} #{path_clause(relation)} #{path_clause_as_subselect(relation, values_stmt, "?s", limit, offset)}.}"
    query_stmt = insert_order_by_subject(query_stmt)
    # if limit > 0
    #   query_stmt << " OFFSET #{offset} LIMIT #{limit}"
    # end
    puts query_stmt
    
    get_results(query_stmt, relation)
  end
  
  def accept_path_clause?
    false
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
  
  def group_by(nodes, relation)
    if nodes.empty?
      return []
    end
    if relation.nil?
      raise MissingRelationException
    end
    images = restricted_image(relation: relation, restriction: nodes)
    reversed_relation = relation.reverse
    
    groups_hash = {}
    images.each do |node|
      if(!groups_hash.has_key? node.item)
        groups_hash[node.item] = Node.new(node.item)
      end
      
      reversed_relation_node = groups_hash[node.item].children[0]
      # binding.pry
      if !reversed_relation_node
        reversed_relation_node = Node.new(reversed_relation)
        if(node.parent.is_a? Xplain::Literal)
          reversed_relation_node.children_edges = []
        else
          reversed_relation_node.children_edges = Set.new
        end        
        groups_hash[node.item].children_edges = [Edge.new(groups_hash[node.item], reversed_relation_node)]
      end
      # binding.pry
      reversed_relation_node.children_edges << Edge.new(reversed_relation_node, Node.new(node.parent.item))
    end
    # binding.pry
    groups_hash.values
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
  
  # def zero_empty_results(input_nodes, result_set)
  #   if(result_set.empty?)
  #     return input_nodes.map{|n| n.copy}
  #   end
  #
  #   result_set += (input_nodes - result_set)
  #
  #   result_set.each do |node|
  #     if node.children_edges.empty?
  #       node.children_edges = [Edge.new(node, Xplain::Literal.new(0.0))]
  #     end
  #   end
  #   result_set
  # end
  
  
  def filter(input_nodes, filter_expr)
    if input_nodes.empty?
      return []
    end
    dataset_filter(input_nodes, filter_expr)
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
  
  def dataset_filter(input_nodes = [], filter_expr)
    interpreter = SPARQLFilterInterpreter.new()
    parsed_query = interpreter.parse(filter_expr)
    query = "SELECT ?s where{"
    query << values_clause("?s", input_nodes.map{|n|n.item})
    query << parsed_query + "}"
    get_filter_results(query)
  end
  
  def can_aggregate?(items, aggregation_function)
    true
  end
  
  
  def convert_results(results_hash)
  end
  
  class QueryResults
    attr_accessor :results
    def initialize(results)
      @results = results
    end
  end

end