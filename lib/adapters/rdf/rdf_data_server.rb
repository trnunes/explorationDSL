require 'rdf'
require 'sparql/client'

class RDFDataServer
  attr_accessor :graph, :limit , :offset, :namespace_map, :label_property, :items_limit, :use_select, :content_type, :api_key, :cache


  def initialize(graph, options = {})
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
    @cache = RDFCache.new(@cache_max_size)
    
    
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
  def path_string(relations)
    relations.map{|r| "<" << Xpair::Namespace.expand_uri(r.to_s) << ">"}.join("/")
    
  end

  def begin_nav_query(&block)
    t = SPARQLQuery::NavigationalQuery.new(self)
    if block_given?
      yield(t)
    else
      t
    end
    t
  end
  
  def types
    limit = 10
    offset = 0
    query = "SELECT DISTINCT ?class WHERE { ?s a ?class.}"
    classes = []
    execute(query, content_type: content_type).each do |s|
      type = Type.new(s[:class].to_s)
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
      item = Entity.new(s[:s].to_s)
      # item.text = s[:label].to_s if !s[:label].to_s.empty?
      item.add_server(self)
      instances << item
    end
    instances
  end
  
  def relations
    query = "SELECT DISTINCT ?relation WHERE { ?s ?relation ?o.}"
    classes = []
    execute(query, content_type: content_type).each do |s|
      relation = Relation.new(s[:relation].to_s)
      # relation.text = s[:label].to_s if !s[:label].to_s.empty?
      relation.add_server(self)
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
    query = "SELECT distinct ?s WHERE{?s ?p ?o. FILTER(#{filters.join(" && ")}) } "
    execute(query,content_type: content_type ).each do |s|
      item = Entity.new(s[:s].to_s)
      item.add_server(self)
      items << item
    end
    items
  end
  
  def blaze_graph_search(keyword_pattern)
    filters = []
    unions = []
    items = []
    query = "select ?s ?p ?o where {?o <http://www.bigdata.com/rdf/search#search> \" #{keyword_pattern.join(" ")}\". ?o <http://www.bigdata.com/rdf/search#matchAllTerms> \"true\" . ?s ?p ?o .}"


    execute(query,content_type: content_type ).each do |s|
      item = Entity.new(s[:s].to_s)
      item.add_server(self)
      items << item
    end
    items
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
    query = @graph.query("SELECT distinct ?p ?label WHERE{?s ?p ?o. OPTIONAL{?p <#{@label_property}> ?label}")
    query.each_solution do |solution|
      relation = Relation.new(solution[:p].to_s)
      relation.text = solution[:label].to_s
      relation.add_server(self);
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
    
  def image(relation, restriction=[] &block)
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
    # if self.cache.has_key? query
    #   return @cache[query].results
    # end
    
    puts query.to_s

    # while(!rs.empty?)

      limited_query = query #+ "limit #{@limit} offset #{offset}"



      rs = @graph.query(limited_query, options)      
      rs_a = rs.to_a
      

      solutions += rs_a
    #   break if rs_a.size < @limit
    #   offset += limit + 1
    # end
    # self.cache[query] = QueryResults.new(solutions)
    solutions
  end
  
  class QueryResults
    attr_accessor :results
    def initialize(results)
      @results = results
    end
  end 


end