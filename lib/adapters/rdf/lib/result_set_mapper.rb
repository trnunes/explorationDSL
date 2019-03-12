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
      result_set_load_all.each{|rs| result_set_delete rs}
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
      SELECT ?node ?nodeText ?nodeIndex ?item ?itemType ?child ?childIndex ?childText ?child_item ?childType ?nodeTextProp ?childTextProp
      WHERE{
        ?node <#{xplain_namespace}included_in> #{result_set_uri}.
        ?node <#{@xplain_ns.uri}index> ?nodeIndex.
        OPTIONAL{?node <#{xplain_namespace}has_item> ?item. ?item <#{xplain_namespace}item_type> ?itemType}.
        OPTIONAL{ ?node <#{@xplain_ns.uri}text_relation> ?nodeTextProp}.
        OPTIONAL{ ?node <#{@xplain_ns.uri}has_text> ?nodeText}.
        OPTIONAL{?node <#{xplain_namespace}children> ?child. ?child <#{@xplain_ns.uri}index> ?childIndex.
                ?child <#{xplain_namespace}has_item> ?child_item.  
                OPTIONAL{?child <#{@xplain_ns.uri}text_relation> ?childTextProp.}. OPTIONAL{?child_item <#{xplain_namespace}item_type> ?childType}.}.
      } ORDER BY xsd:integer(?nodeIndex) xsd:integer(?childIndex)"
      
      nodes = []
      nodes_hash = {}
      
      untitled_items = []
      puts "-------RS QUERY---------"
      puts query
      # binding.pry
      @graph.query(query).each do |solution|
        next if !solution[:node] || !solution[:item]
        
        node_id = solution[:node].to_s.gsub(xplain_namespace, "")
        if solution[:itemType].to_s.include? "Literal"
          item = build_literal solution[:nodeText].to_s, solution[:datatype].to_s
        else
          item = build_item solution[:item], solution[:itemType]
        end
        
        
        if !item.is_a?(Xplain::Literal)
          item.text_relation = Xplain::Namespace.colapse_uri solution[:nodeTextProp].to_s
          if item.text_relation != "xplain:has_text" && solution[:nodeText].to_s.empty? && !item.is_a?(Xplain::Literal)
            untitled_items << item
          end
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
              if solution[:childType].to_s.include? "Literal"
                child_item = build_literal solution[:childText].to_s, solution[:child_datatype].to_s
              else
                child_item = build_item solution[:child_item], solution[:childType]
              end
              
              if !child_item.is_a?(Xplain::Literal)
                child_item.text = solution[:childText].to_s
                child_item.text_relation = Xplain::Namespace.colapse_uri solution[:childTextProp].to_s
                if child_item.text_relation != "xplain:has_text" && solution[:childText].to_s.empty? && !child_item.is_a?(Xplain::Literal)
                  untitled_items << child_item
                end 
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
      # binding.pry
      #TODO when allowing multiple repositories, correct this
      if !untitled_items.empty?
        
        Xplain::default_server.set_items_texts untitled_items
      end
      
      if !intention.to_s.empty?
        intention_desc = eval(intention)
      end
      Xplain::ResultSet.new(id: rs_id, nodes: first_level, intention: intention_desc, title: title, notes: notes.to_a)
      
    end
    def set_items_texts(items)
      items_hash = {} 
      items.each do |item|
        if !items_hash.has_key? item.id
          items_hash[item.id] = []
        end
        items_hash[item.id] << item
      end  
      values_s = "VALUES ?s{ " << items_hash.keys.map{|id| "<#{id}>"}.join(" ") << "}"
      
      values_p = "VALUES ?p{ " << items.map{|item| "<#{Xplain::Namespace.expand_uri(item.text_relation)}>"}.uniq.join(" ") << "}"
      query = "SELECT * WHERE{?s ?p ?text. #{values_s}. #{values_p}}"
      puts "-------TEXT QUERY---------"
      puts query
      @graph.query(query).each_solution do |solution|
        items_hash[solution[:s].to_s].each{|item| item.text = solution[:text].to_s}
      end
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
      insert_stmt = "<#{@xplain_ns.uri + node.id}> #{included_in_pred} #{result_set_uri}. "
      item_uri = ""
      if node.item.is_a? Xplain::Literal
        literal_id = SecureRandom.uuid
        item_uri = "<#{@xplain_ns.uri}literal/#{literal_id}>"
        insert_stmt += "#{item_uri} <#{@xplain_ns.uri}datatype> \"#{node.item.datatype}\"."
      else
        item_uri = parse_item(node.item)
      end
      
      
      
      insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@xplain_ns.uri}has_item> #{item_uri}."
      
      insert_stmt += "#{item_uri} <#{@xplain_ns.uri}item_type> \"#{node.item.class.name}\"."
      
      if !node.item.is_a? Xplain::Literal 
        insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@xplain_ns.uri}text_relation>  <#{Xplain::Namespace.expand_uri node.item.text_relation}> ."
      end
      
      if node.item.text_relation == "xplain:has_text"
        insert_stmt += "<#{@xplain_ns.uri + node.id}> <#{@xplain_ns.uri}has_text>  \"#{node.item.text}\" ."
      end

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