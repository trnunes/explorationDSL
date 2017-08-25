require 'rdf'
require 'sparql/client'
require 'time'
class RDFDataServer
  attr_accessor :graph, :limit , :offset, :namespace_map, :label_property, :items_limit, :use_select, :content_type, :api_key, :cache, :last_query
  


  def initialize(graph, options = {})
    options[:read_timeout] = 3000
    @graph = SPARQL::Client.new graph, options
    @limit = options[:limit]
    @limit ||= 5000
    @label_property = options[:label_property]
    @or_clause = false
    @namespace_map = {}
    @items_limit = options[:items_limit]
    @items_limit ||= 300
    @use_select = options[:use_select]
    @use_select ||= false
    @content_type = options[:content_type]
    @content_type ||= "application/sparql-results+xml"
    @api_key = options[:api_key]
    @cache_max_size = options[:cache_limit]
    @cache_max_size ||= 20000
    @cache = {}
    @last_query = "select * where{?s ?p ?o} limit 20"
    
    
  end

  def add_namespace(namespace_prefix, namespace)
    @namespace_map[namespace_prefix] = namespace
  end
  
  def build_literal(literal)
    if (literal.respond_to?(:datatype) && !literal.datatype.to_s.empty?)
      Xpair::Literal.new(literal.to_s, literal.datatype.to_s)
    else
      if literal.to_s.match(/\A[-+]?[0-9]+\z/).nil?
        Xpair::Literal.new(literal.to_s)
      else
        Xpair::Literal.new(literal.to_s.to_i)
      end      
    end
  end
  
  def size
    @graph.count
  end
  
  def accept_path_query?
    true
  end
  def path_string(relations)
    relations.map{|r| "<" << Xpair::Namespace.expand_uri(r.to_s) << ">"}.join("/")
    
  end
  
  def get_xsd_timestamp
    # timestamp = Time.new
    # datetime = timestamp.year.to_s + "-" + timestamp.month.to_s + "-" + timestamp.day.to_s + "T" + timestamp.hour.to_s + ":" + timestamp.min.to_s + ":" + timestamp.sec.to_s
    datetime = Time.now.iso8601
    "\"#{datetime}\"^^xsd:dateTime"
  end
  
  def save_expression(session_id, expression)
    contains_expression_property = "http://tecweb.inf.puc-rio.br/containsExpression"
    expression_code_property = "http://tecweb.inf.puc-rio.br/code"
    timestamp_property = "http://tecweb.inf.puc-rio.br/timestamp"
    expression_uri = "http://tecweb.inf.puc-rio.br/expression/" + SecureRandom.uuid.to_s
    
    query = "INSERT DATA{ <#{session_id}> <#{contains_expression_property}> <#{expression_uri}>. <#{expression_uri}> <#{timestamp_property}> #{get_xsd_timestamp}. <#{expression_uri}> <#{expression_code_property}> \"#{expression.gsub("\"", "\\\"")}\"}"

    execute_update(query, content_type: content_type)
  end
  
  def save_session(session)
    property = "http://tecweb.inf.puc-rio.br/sessionStart"
    session
    if session.id.nil?
      session.id = "http://tecweb.inf.puc-rio.br/session/" + SecureRandom.uuid
      query = "INSERT DATA{ <#{session.id}> <#{property}> #{get_xsd_timestamp}.}"
      execute_update(query, content_type: content_type)
    end
  end

  def begin_nav_query(options = {}, &block)
    t = SPARQLQuery::NavigationalQuery.new(self)
    if(options[:limit].to_i > 0)
      t.limit = options[:limit].to_i
    end
    
    if block_given?
      yield(t)
    else
      t
    end
    t
  end
  
  def find_range_types(relation)
    query = "SELECT DISTINCT ?c WHERE{?s a ?c. ?s <#{Xpair::Namespace.expand_uri(relation.to_s)}> ?o.}"
    classes = []
    execute(query, content_type: content_type).each do |s|
      type = Type.new(Xpair::Namespace.colapse_uri(s[:c].to_s))
      # type.text = s[:label].to_s if !s[:label].to_s.empty?
      type.add_server(self)
      classes << type
    end
    {relation => {"xplain:range" => classes}}
  end
  
  def find_domain_types(relation)
    query = "SELECT DISTINCT ?c WHERE{?o a ?c. ?s <#{Xpair::Namespace.expand_uri(relation.to_s)}> ?o.}"
    classes = []
    execute(query, content_type: content_type).each do |s|
      type = Type.new(Xpair::Namespace.colapse_uri(s[:c].to_s))
      # type.text = s[:label].to_s if !s[:label].to_s.empty?
      type.add_server(self)
      classes << type
    end
    {relation => {"xplain:domain" => classes}}
  end
  
  def find_relations_for_type(type)
    query = "SELECT DISTINCT ?p WHERE{?s ?p ?c. ?c a <#{Xpair::Namespace.expand_uri(type.to_s)}>}"
    relations = []
    execute(query, content_type: content_type).each do |s|
      relation = SchemaRelation.new(Xpair::Namespace.colapse_uri(s[:p].to_s), false, self)
      # relation.text = s[:label].to_s if !s[:label].to_s.empty?
      relation.server = self
      relations << relation
    end
    {type => {"xplain:ofType" => relations}}
  end
  
  def sample_type(relation_uri, items, inverse = false)
    types = Xpair::Visualization.types
    types.delete("http://www.w3.org/2000/01/rdf-schema#Resource")
    retrieved_types = []
    if(types.size > 0 && !items[0].is_a?(Xpair::Literal))
      types_values_clause = "VALUES ?t {#{types.map{|t| "<" + Xpair::Namespace.expand_uri(t) + ">"}.join(" ")}}"
      items_values_clause = "VALUES ?s {#{items[0..5].map{|i| "<" + Xpair::Namespace.expand_uri(i.id) + ">"}.join(" ")}}"
      if inverse
        query = "SELECT distinct ?t WHERE{#{items_values_clause}. #{types_values_clause}. ?o #{relation_uri} ?s. ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t}"
      else
        query = "SELECT distinct ?t WHERE{#{items_values_clause}. #{types_values_clause}. ?s #{relation_uri} ?o. ?o <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t}"
      end
      
      execute(query, content_type: content_type).each do |s|
        retrieved_types << Xpair::Namespace.expand_uri(s[:t].to_s)
      end
    end
    types_with_vis_properties = (retrieved_types & types)
    types_with_vis_properties.empty? ? "rdfs:Resource" : types_with_vis_properties.first
  end
  
  def types
    limit = 10
    offset = 0
    query = "SELECT DISTINCT ?class WHERE { ?s a ?class.}"
    classes = []
    execute(query, content_type: content_type).each do |s|
      type = Type.new(Xpair::Namespace.colapse_uri(s[:class].to_s))
      # type.text = s[:label].to_s if !s[:label].to_s.empty?
      type.add_server(self)
      classes << type
    end
    classes
  end
  
  def instances(type)
    query = "SELECT DISTINCT ?s  WHERE { ?s a <#{Xpair::Namespace.expand_uri(type.id)}>.}"
    instances = []
    execute(query, content_type: content_type).each do |s|
      item = Entity.new(Xpair::Namespace.colapse_uri(s[:s].to_s))
      # item.text = s[:label].to_s if !s[:label].to_s.empty?
      item.add_server self
      instances << item
    end
    instances
  end
  
  def relations
    query = "SELECT DISTINCT ?relation WHERE { ?s ?relation ?o.}"
    classes = []
    execute(query, content_type: content_type).each do |s|
      relation = SchemaRelation.new(Xpair::Namespace.colapse_uri(s[:relation].to_s), false, self)
      # relation.text = s[:label].to_s if !s[:label].to_s.empty?
      relation.server = self
      classes << relation
    end
    classes    
  end
  
  def search(keyword_pattern)
    filters = []
    unions = []
    items = []
    keyword_pattern.each do |pattern|
      filters << "(regex(str(?o), \"#{pattern}\"))"
    end

    label_clause = SPARQLQuery.label_where_clause("?s", "rdfs:Resource")
    query = "SELECT distinct ?s ?lo WHERE{?s ?p ?o. #{label_clause}  FILTER(#{filters.join(" && ")}) } "
    execute(query,content_type: content_type ).each do |s|
      item = Entity.new(Xpair::Namespace.colapse_uri(s[:s].to_s))
      item.add_server(self)
      items << item
    end
    items
  end
  
  def blaze_graph_search(keyword_pattern)
    filters = []
    unions = []
    items = []
    label_clause = SPARQLQuery.label_where_clause("?s", Xpair::Visualization.label_relations_for("rdfs:Resource"))
    label_clause = " OPTIONAL " + label_clause if !label_clause.empty?
    query = "select ?s ?p ?o ?ls where {?o <http://www.bigdata.com/rdf/search#search> \" #{keyword_pattern.join(" ")}\". ?o <http://www.bigdata.com/rdf/search#matchAllTerms> \"true\" . ?s ?p ?o . #{label_clause}}"


    execute(query,content_type: content_type ).each do |s|
      item = Entity.new(Xpair::Namespace.colapse_uri(s[:s].to_s),  "rdfs:Resource")
      item.text = s[:ls].to_s
      item.add_server(self)
      items << item
    end
    items.sort{|i1, i2| i1.text <=> i2.text}
  end
  
  

  def begin_filter(&block)
    f = SPARQLQuery::SPARQLFilter::ANDFilter.new(self)
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
    query = @graph.query("SELECT distinct ?p ?label WHERE{?s ?p ?o. OPTIONAL{?p <#{Xpair::Namespace.expand_uri("rdfs:label")}> ?label}")
    query.each_solution do |solution|
      relation = SchemaRelation.new(Xpair::Namespace.colapse_uri(solution[:p].to_s))
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
      item = Entity.new(solution[:s].to_s)
      item.add_server(self)  
      items << item
      # 
      block.call(item) if !block.nil?
    end       
    items
  end
    
  def image(relation, restriction=[], &block)
    items = []
    values_stmt = ""
    if(!restriction.empty?)
      values_stmt = "VALUES ?s {#{restriction.map{|item| "<" + Xpair::Namespace.expand_uri(item.id) + ">"}.join(" ")}}"
    end
    
    query_stmt = "SELECT distinct ?o where{#{values_stmt} ?s <#{Xpair::Namespace.expand_uri(relation.id)}> ?o}"
    query = @graph.query(query_stmt)
    query.each_solution do |solution|
      item = Entity.new(solution[:o].to_s)
      item.add_server(self)  
      items << item
      if block_given?
        block.call(item)
      end
    end       
    items
  end

  def domain(relation, restriction=[], &block)
    items = []
    values_stmt = ""
    if(!restriction.empty?)
      values_stmt = "VALUES ?o {#{restriction.map{|item| "<" + Xpair::Namespace.expand_uri(item.id) + ">"}.join(" ")}}"
    end
    query_stmt = "SELECT distinct ?s where{#{values_stmt} ?s <#{Xpair::Namespace.expand_uri(relation.id)}> ?o.}"
    query = @graph.query(query_stmt)
    query.each_solution do |solution|
      item = Entity.new(solution[:s].to_s)
      item.add_server(self)  
      items << item
      if block_given?
        block.call(item)
      end
    end       
    items
  end
  
  
 
  def execute(query, options = {})
    solutions = []

    offset = 0
    rs = [0]
    if self.cache.has_key? query
      puts "CACHED!"
      return @cache[query]
    end

    puts query.to_s
    puts "NOT CACHED!"
    # while(!rs.empty?)

      limited_query = query #+ "limit #{@limit} offset #{offset}"
      # binding.pry


      rs = @graph.query(limited_query, options) 
      rs_a = rs.to_a
      puts "=-=========FINISHED============"

      solutions += rs_a
    #   break if rs_a.size < @limit
    #   offset += limit + 1
    # end
    # self.cache[query] = QueryResults.new(solutions)
    @cache[limited_query] = solutions
    solutions
  end
  
  def execute_update(query, options = {})
    puts query
    rs = @graph.update(query) 
    puts "UPDATE RESULTS: " << rs.inspect
  end
  
  class QueryResults
    attr_accessor :results
    def initialize(results)
      @results = results
    end
  end 


end