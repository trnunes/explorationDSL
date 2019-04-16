module Xplain::RDF
  class DataServer
    include Xplain::RDF::RelationMapper
    include Xplain::RDF::ResultSetMapper
    include Xplain::RDF::SessionMapper
    include Xplain::GraphConverter
  
    attr_accessor :graph, :url, :items_limit, :content_type, :api_key, :cache, :filter_intepreter, :record_intention_only, :params
  
  
    def initialize(params = {})
      @params = params
      setup params    
    end
    
    def setup(options)
      
      @graph = SPARQL::Client.new options[:graph], options
      @url = options[:graph]
      @content_type = options[:content_type] || "application/sparql-results+xml"
      @api_key = options[:api_key]
      @cache_max_size = (options[:cache_limit] || 20000).to_i
      @items_limit = (options[:items_limit] || 0).to_i
      @results_limit = (options[:limit] || 5000).to_i
      @record_intention_only = options[:record_intention_only]
      @record_intention_only ||= false
      
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
        item = Xplain::Entity.create(Xplain::Namespace.colapse_uri(s[:s].to_s), s[:ls].to_s)
        item.add_server(self)
        retrieved_items << item
      end
      
      retrieved_items.to_a
    end
    
      
    def each_item(&block)
      items = []
      query = @graph.query("SELECT ?s WHERE{?s ?p ?o.}")
      query.each_solution do |solution|
        item = Xplain::Entity.create(solution[:s].to_s)
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
  
      # puts limited_query
      rs = @graph.query("PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> " << limited_query, options)      
      rs_a = rs.to_a
      
      solutions += rs_a
      solutions
    end
    
    ###
    ### return: the nodes grouped by the image items of the relation. 
    ### The relation returned is the inverse of _relation arg 
    ###
    
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
    
    
    
    def execute_update(query, options = {})
      
      begin
        # puts query
        rs = @graph.update(query, options)
      rescue Exception => e
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
      items_h = input_items.map{|i| [i.id, i]}.to_h
      results.map{|i| items_h[i.id]}
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
    
    def paginate(items_list, page_size)
      
      return [items_list] if !(page_size.to_i > 0)
      
      offset = 0
      pages = []
      while offset < items_list.size
        pages << items_list[offset..(offset+page_size)]
        offset += page_size
      end
      pages
    end
    
    def to_ruby
      DSLParser.new.parse_data_server(self) 
    end
    
  end
end
