module Xplain::RDF
  module ResultSetMapper
    def result_set_count
      rs = execute("SELECT distinct ?s where {?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>}")
      rs.size
    end
    
    #TODO preventing saving sets already save and unmodified
    def result_set_save(result_set)
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
    
    def result_set_find_by_node_id(node_id)
      rs_query = "SELECT ?o WHERE{<#{@xplain_ns.uri + node_id}> <#{@xplain_ns.uri}included_in> ?o}"
      rs_uri = nil
      @graph.query(rs_query).each do |solution|
        rs_uri = solution[:o].to_s
      end
      if rs_uri
        [result_set_load(rs_uri.gsub(@xplain_ns.uri, ""))]
      end
    end
    
    def result_set_delete_all
      result_set_load_all.each{|rs| delete_resultset rs}
    end
    
    def result_set_delete(result_set)
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
    
    #TODO document options
    def result_set_load_all(options={})
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
      set_id_list.map{|id| result_set_load(id)}
    end
      
    def result_set_load(rs_id)
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
      
      
      @graph.query(query).each do |solution|
        next if !solution[:node] || !solution[:item]
        
        node_id = solution[:node].to_s.gsub(xplain_namespace, "")
        item = build_item solution[:item], solution[:itemType]
        
        if !item.is_a?(Xplain::Literal)
          item.text = solution[:nodeText].to_s
        end
        
        node = nodes_hash[node_id]
        if !node
          node = Xplain::Node.new(id: node_id, item: item)
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
              cnode = Xplain::Node.new(id: child_id, item: child_item)
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
      Xplain::ResultSet.new(id: rs_id, nodes: first_level, intention: intention_desc, title: title, notes: notes.to_a)
      
    end
    
    #TODO Document options: exploration_only
    def result_set_find_by_session(session, options={})
      rs_uri_query = "SELECT ?o ?i WHERE{<#{@xplain_ns.uri + session.id}> <#{@xplain_ns.uri}contains_set> ?o.  OPTIONAL{?o <#{@xplain_ns.uri}intention> ?i}"
      if options[:exploration_only]
        rs_uri_query << " BIND (COALESCE(?i, \"no intention\") as ?i) FILTER NOT EXISTS {FILTER (regex(str(?i), \"visual: \s*true\",\"i\")) }." 
      end
      rs_uri_query << "}"
  
      result_set_ids = []
      @graph.query(rs_uri_query).each_solution do |solution|
        result_set_ids << solution[:o].to_s.gsub(@xplain_ns.uri, "")
      end
      result_set_ids.map{|id| result_set_load(id)}
    end
    
    #private
    def generate_insert(index, node, result_set)
      if !node.id
        node.id = SecureRandom.uuid
      end
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
  end
end