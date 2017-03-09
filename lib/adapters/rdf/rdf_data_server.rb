require 'rdf'
require 'sparql/client'

class RDFDataServer
  attr_accessor :graph, :limit , :offset  


  def initialize(graph)
    @graph = SPARQL::Client.new graph
    @or_clause = false
  end
  
  def size
    @graph.count
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
    query = "SELECT DISTINCT ?class WHERE { ?s a ?class .}"
    classes = []
    execute(query).each_solution do |s|
      type = Type.new(s[:class].to_s)
      type.add_server(self)
      classes << type
    end
    classes
  end
  
  def instances(type)
    query = "SELECT DISTINCT ?s WHERE { ?s a <#{type.id}> .}"
    instances = []
    execute(query).each_solution do |s|
      item = Entity.new(s[:s].to_s)
      item.add_server(self)
      instances << item
    end
    instances
  end
  
  def relations
    query = "SELECT DISTINCT ?relation WHERE { ?s ?relation ?o .}"
    classes = []
    execute(query).each_solution do |s|
      relation = Relation.new(s[:relation].to_s)
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
      filters << "(regex(str(?s), \"#{pattern}\") || regex(str(?o), \"#{pattern}\"))"
    end

    query = "SELECT distinct ?s WHERE{?s ?p ?o. FILTER(#{filters.join(" && ")}) } "
    execute(query).each_solution do |s|
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
    query = @graph.query("SELECT distinct ?p WHERE{?s ?p ?o.}")
    query.each_solution do |solution|
      relation = Relation.new(solution[:p].to_s)  
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
    
  def image(relation)
    @select_clauses << "DISTINCT ?o"
    relation_uri = search_uri(relation)
    if(relation_uri.nil?)
      @where_clauses << "?s ?p ?o"
      @filters << "FILTER regex(str(?p), \"#{relation_uri.to_s}\", \"i\")."
    else
      @where_clauses << "?s <#{relation_uri.to_s}> ?o"
    end
    self
  end

  def domain(relation)
    @select_clauses << "DISTINCT ?s"
    relation_uri = search_uri(relation)

    if(relation_uri.nil?)
      @where_clauses << "?s ?p ?o"
      @filters << "FILTER regex(str(?p), \"#{relation.to_s}\", \"i\")."
    else
      @where_clauses << "?s <#{relation_uri.to_s}> ?o"
    end
    self
  end
 
  def execute(query)

    @graph.query(query)
  end 


end