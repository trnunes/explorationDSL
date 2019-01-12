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
    @cache_max_size = (options[:cache_limit] || 20000).to_i
    @items_limit = (options[:items_limit] || 0).to_i
    @results_limit = (options[:limit] || 5000).to_i
    
    #Default Namespaces
    Xplain::Namespace.new("owl", "http://www.w3.org/2002/07/owl#")
    Xplain::Namespace.new("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
    @xsd_ns = Xplain::Namespace.new("xsd", "http://www.w3.org/2001/XMLSchema#")
    @rdf_ns = Xplain::Namespace.new("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @dcterms = Xplain::Namespace.new("dcterms", "http://purl.org/dc/terms/")
    Xplain::Namespace.new("foaf", "http://xmlns.com/foaf/0.1/")
    Xplain::Namespace.new("rss", "http://purl.org/rss/1.0/")
    @xplain_ns = Xplain::Namespace.new("xplain", "http://tecweb.inf.puc-rio.br/xplain/")
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
    retrieved_items = Set.new
    label_relations = Xplain::Visualization.label_relations_for("rdfs:Resource")    
    values_p = values_clause("?p", label_relations.map{|id| "<#{id}>"})
    
    filter_clause = "regex(str(?ls), \".*#{keyword_pattern.join(' ')}.*\")" 
    query = "SELECT distinct ?s ?ls WHERE{
      #{values_clause("?s", restriction_nodes.map{|n|n.item})} 
      #{values_p} {?s ?p ?ls}. FILTER(#{filter_clause}).}"
    

    if Xplain::Namespace.expand_uri(keyword_pattern.join('').strip) =~ URI::regexp
      url = Xplain::Namespace.expand_uri(keyword_pattern.join('').strip)
      query = "SELECT distinct ?s ?ls WHERE{ VALUES ?s{<#{url}>} #{values_p} {?s ?p ?ls}.}"
    end
    
    execute(query, {content_type: content_type, offset: offset, limit: limit}).each do |s|
      item = Xplain::Entity.new(Xplain::Namespace.colapse_uri(s[:s].to_s), s[:ls].to_s)
      item.add_server(self)
      retrieved_items << item
    end
    
    retrieved_items.to_a
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
  
  def count_resultsets
    rs = execute("SELECT distinct ?s where {?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>}")
    rs.size
  end
  
  #TODO preventing saving sets already save and unmodified
  def save_resultset(result_set)
    #TODO save title
    #TODO save annotations
    namespace = "http://tecweb.inf.puc-rio.br/xplain/"
    result_set_uri = "<#{namespace + result_set.id}>"
    result_set_type_uri = "<#{namespace + "ResultSet"}>"
    insert_rs_query = "INSERT DATA{ " + result_set_uri + " <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> " + result_set_type_uri + "."
    insert_rs_query << "#{result_set_uri} <http://purl.org/dc/terms/title> \"#{result_set.title}\". "
    intention_parser = DSLParser.new
    if result_set.intention
      insert_rs_query << "#{result_set_uri} <#{namespace}intention> \"#{intention_parser.to_ruby(result_set.intention).gsub("\"", '\"').gsub("\n", "\\n")}\". "
    end
    
    result_set.annotations.each do |note|
      insert_rs_query << "#{result_set_uri} <#{namespace}note> \"#{note}\". "
    end
     
    insert_rs_query << "}"
    execute_update(insert_rs_query, content_type: content_type)
    query = "INSERT DATA{ "  
    index = 0
    result_set.each{|node| query << generate_insert(index += 1, node, result_set)}
    query << "}"
    execute_update(query, content_type: content_type)
  end
  
  def resultset_by_node_id(node_id)
    rs_query = "SELECT ?o WHERE{<#{@xplain_ns.uri + node_id}> <#{@xplain_ns.uri}included_in> ?o}"
    rs_uri = nil
    @graph.query(rs_query).each do |solution|
      rs_uri = solution[:o].to_s
    end
    if rs_uri
      [load_resultset(rs_uri.gsub(@xplain_ns.uri, ""))]
    end
  end
  
  def delete_all_resultsets
    load_all_resultsets.each{|rs| delete_resultset rs}
  end
  
  def delete_resultset(result_set)
    #TODO the index triples may not be removed if the ordering of the items change for some reason. Remove all oh them!
    namespace = "http://tecweb.inf.puc-rio.br/xplain/"
    result_set_uri = "<#{namespace + result_set.id}>"
    result_set_type_uri = "<#{namespace + "ResultSet"}>"
    insert_rs_query = "DELETE DATA{ " + result_set_uri + " <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> " + result_set_type_uri + "."
    insert_rs_query << "#{result_set_uri} <http://purl.org/dc/terms/title> \"#{result_set.title}\". "
    intention_parser = DSLParser.new
    if result_set.intention
      insert_rs_query << "#{result_set_uri} <#{namespace}intention> \"#{intention_parser.to_ruby(result_set.intention).gsub("\"", '\"').gsub("\n", "\\n")}\". "
    end
    
    result_set.annotations.each do |note|
      insert_rs_query << "#{result_set_uri} <#{namespace}note> \"#{note}\". "
    end
     
    insert_rs_query << "}"
    execute_update(insert_rs_query, content_type: content_type)
    query = "DELETE DATA{ "  
    index = 0  
    result_set.each do |node|
       
      query << generate_insert(index += 1, node, result_set)
    end
    query << "}"
    execute_update(query, content_type: content_type)
  end
  
  def generate_insert(index, node, result_set)
    included_in_pred = "<#{@xplain_ns.uri}included_in>"
    result_set_uri = "<" + @xplain_ns.uri + result_set.id + ">"
    item_uri = parse_item(node.item)
    
    insert_stmt = "<#{@xplain_ns.uri + node.id}> #{included_in_pred} #{result_set_uri}. "
    insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@xplain_ns.uri}has_item> #{item_uri}."
    if [Xplain::SchemaRelation, Xplain::PathRelation, Xplain::Type, Xplain::Entity].include? node.item.class
      insert_stmt += "#{item_uri} <#{@xplain_ns.uri}item_type> \"#{node.item.class.name}\"."
    end
    insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@xplain_ns.uri}item_type> #{item_uri}."
    insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@dcterms.uri}title> \"#{node.item.text}\"."
    insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@xplain_ns.uri}index> #{index}."
    child_index = 0
    node.children.each do |child|
      insert_stmt += generate_insert(child_index += 1, child, result_set)
      child_uri = "<#{@xplain_ns.uri + child.id}>"
      insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@xplain_ns.uri}children> #{child_uri}. "
    end
    insert_stmt
  end
  #TODO document options
  def load_all_resultsets(options={})
    query = "SELECT ?s ?i WHERE{?s <#{@rdf_ns.uri}type> <#{@xplain_ns.uri}ResultSet>. OPTIONAL{?s <#{@xplain_ns.uri}intention> ?i} "
    if options[:exploration_only]
      query << " FILTER NOT EXISTS {FILTER (regex(?i, \"visual: \s*true\",\"i\")) }." 
    end
    query << "}"

    solutions = @graph.query(query)
    set_id_list = []
    solutions.each do |sol|
      set_id_list << sol[:s].to_s.gsub(@xplain_ns.uri, "")
    end
    set_id_list.map{|id| load_resultset(id)}
  end
    
  def load_resultset(rs_id)
    #TODO implement for literal items
    xplain_namespace = "http://tecweb.inf.puc-rio.br/xplain/"
    result_set_uri = "<#{xplain_namespace + rs_id}>"
    
    result_set_query = "SELECT ?title ?note ?intention where{#{result_set_uri} <http://purl.org/dc/terms/title> ?title. OPTIONAL{#{result_set_uri} <#{xplain_namespace}note> ?note}. OPTIONAL{#{result_set_uri} <#{xplain_namespace}intention> ?intention }.}"
    title = ""
    intention = ""
    notes = Set.new
    @graph.query(result_set_query).each do |solution|
      title = solution[:title].to_s
      if solution[:note]
        notes << solution[:note].to_s
      end
      intention = solution[:intention].to_s
    end
    
    query = "prefix xsd: <#{@xsd_ns.uri}> 
    SELECT ?node ?nodeText ?nodeIndex ?item ?itemType ?child ?childIndex ?childText ?child_item ?childType
    WHERE{OPTIONAL{?node <#{xplain_namespace}included_in> #{result_set_uri}.
      ?node <#{@xplain_ns.uri}index> ?nodeIndex.
      ?node <#{@dcterms.uri}title> ?nodeText. ?node <#{xplain_namespace}has_item> ?item. OPTIONAL{?item <#{xplain_namespace}item_type> ?itemType}.}. 
      OPTIONAL{?node <#{xplain_namespace}children> ?child. ?child <#{@xplain_ns.uri}index> ?childIndex.  
      ?child <#{@dcterms.uri}title> ?childText. ?child <#{xplain_namespace}has_item> ?child_item. OPTIONAL{?child_item <#{xplain_namespace}item_type> ?childType}.}.
    } ORDER BY xsd:integer(?nodeIndex) xsd:integer(?childIndex)"
    
    nodes = []
    nodes_hash = {}
    puts "Loading Result Set..."
    puts query
    @graph.query(query).each do |solution|
      next if !solution[:node] || !solution[:item]
      
      node_id = solution[:node].to_s.gsub(xplain_namespace, "")
      item = build_item solution[:item], solution[:itemType]
      
      if !item.is_a?(Xplain::Literal)
        item.text = solution[:nodeText].to_s
      end
      
      node = nodes_hash[node_id]
      if !node
        node = Node.new(item, node_id)
        nodes_hash[node_id] = node
      end
      
      if solution[:child]
        child_id = solution[:child].to_s.gsub(xplain_namespace, "")
          cnode = nodes_hash[child_id]
          if !cnode
            if !solution[:child_item] 
              raise "Inconsistent Result Set: node must point to an Item!"
            end
            
            child_item = build_item solution[:child_item], solution[:childType]
            if !child_item.is_a?(Xplain::Literal)
              child_item.text = solution[:childText].to_s
            end
            cnode = Node.new(child_item, child_id)
            nodes_hash[child_id] = cnode
          end
          node << cnode
      end
      nodes << node
    end
    #TODO create an array if the elements are literals.
    first_level = Set.new(nodes.select{|n| !n.parent})
    if !intention.to_s.empty?
      intention_desc = eval(intention)
    end
    Xplain::ResultSet.new(rs_id, first_level, intention_desc, title, notes.to_a)
    
  end
  
  def add_result_set(session, result_set)
    insert_stmt = "INSERT DATA{
    <#{@xplain_ns.uri + session.id}> <#{@rdf_ns.uri}type> <#{@xplain_ns.uri}Session>.
    <#{@xplain_ns.uri + session.id}> <#{@dcterms.uri}title> \"#{session.title}\". 
    <#{@xplain_ns.uri + session.id}> <#{@xplain_ns.uri}contains_set> <#{@xplain_ns.uri + result_set.id}>}"
    execute_update(insert_stmt, content_type: content_type)
  end
  
  #TODO Document options: exploration_only
  def find_result_sets_by_session(session, options={})
    rs_uri_query = "SELECT ?o ?i WHERE{<#{@xplain_ns.uri + session.id}> <#{@xplain_ns.uri}contains_set> ?o.  OPTIONAL{?o <#{@xplain_ns.uri}intention> ?i}"
    if options[:exploration_only]
      rs_uri_query << " BIND (COALESCE(?i, \"no intention\") as ?i) FILTER NOT EXISTS {FILTER (regex(str(?i), \"visual: \s*true\",\"i\")) }." 
    end
    rs_uri_query << "}"

    result_set_ids = []
    @graph.query(rs_uri_query).each_solution do |solution|
      result_set_ids << solution[:o].to_s.gsub(@xplain_ns.uri, "")
    end
    result_set_ids.map{|id| load_resultset(id)}
  end
  
  def find_session_by_title(title)
    session_query = "SELECT ?s WHERE{?s <#{@rdf_ns.uri}type> <#{@xplain_ns.uri}Session>. ?s <#{@dcterms.uri}title> \"#{title}\"}"
    sessions = []
    @graph.query(session_query).each do |solution|
      session_id = solution[:s].to_s.gsub(@xplain_ns.uri, "")
      sessions << Xplain::Session.new(session_id, title)
    end
    sessions
  end
  
  def list_session_titles
    session_query = "SELECT ?t WHERE{?s <#{@rdf_ns.uri}type> <#{@xplain_ns.uri}Session>. ?s <#{@dcterms.uri}title> ?t}"
    titles = []
    @graph.query(session_query).each do |solution|
      titles << solution[:t].to_s
    end
    titles
  end
  
  def delete_session(session)
    
    
    delete_stmt = "DELETE WHERE{<#{@xplain_ns.uri + session.id}> ?p ?o}"
    
    execute_update(delete_stmt, content_type: content_type)
    
  end
  
  def execute_update(query, options = {})
    puts query
    begin
      rs = @graph.update(query, options)
    rescue RDF::ReaderError => e
       
    end  
    
  end
  def dataset_filter(input_items = [], filter_expr)
    interpreter = SPARQLFilterInterpreter.new()
    results = Set.new
    parsed_query = interpreter.parse(filter_expr)
    paginate(input_items, @items_limit).each do |page_items|
      query = "SELECT ?s ?ls where{"
      query << values_clause("?s", page_items)
      query << mount_label_clause("?s", page_items)
      query << parsed_query + "}"
      results += get_filter_results(query)
    end
    results
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