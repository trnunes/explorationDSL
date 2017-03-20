module SPARQLQuery
  class NavigationalQuery
  
    def initialize(server)
      @items = []
      @server = server
      @construct_clauses = []
      @where_clauses = []
      @select_clauses = []
      @filters = []
      @object_index = 0
      @predicate_index = 0
      @relation_object_hash = {}
      @label_property = RDF::RDFS.label.to_s
    end
  
    def search_uri(relation)
      
      Xpair::Namespace.expand_uri(relation.to_s)
      
      # relation_uri = nil
      # RDF::Vocabulary.each do |v|
      #   begin
      #     #
      #     if v.properties.include?(v[relation.to_s])
      #       relation_uri = v[relation.to_s].to_s
      #     end
      #   rescue KeyError => e
      #     #
      #     relation_uri = nil
      #   end
      # end
      # relation_uri
    end
  
    def restricted_image(relation)

      relation_uri = search_uri(relation)

      if @items.empty?
        @select_clauses << "?s ?p ?o"
        if(relation_uri.nil?)
          @where_clauses << "?s ?p ?o. FILTER regex(str(?p), \"#{relation}\")"
        else
          @where_clauses << "?s ?p ?o. FILTER(?p = <#{relation_uri}>)"
        end        

        
      end
      
    
      @items.each do |entity|
        entity_id = Xpair::Namespace.expand_uri(entity.id)
        if relation_uri.nil?
          construct_clause = "<#{entity_id}> ?p#{@predicate_index += 1} ?o#{@object_index += 1}."
          where_clause = "{<#{entity_id}> ?p#{@predicate_index} ?o#{@object_index}. FILTER regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\").}"
        else
          construct_clause = "<#{entity_id}> <#{relation_uri.to_s}> ?o#{@object_index += 1}."
          where_clause = "{<#{entity_id}> <#{relation_uri.to_s}> ?o#{@object_index}.}"
        end
        construct_clause << " ?s#{@object_index} <#{@label_property}> ?label."
        where_clause <<  " UNION {?s#{@object_index} <#{@label_property}> ?label.}"  
        @construct_clauses << construct_clause
        @where_clauses << where_clause
      end
      self
    end

    def restricted_domain(relation)
    
      relation_uri = search_uri(relation)
      if @items.empty?
        @select_clauses << "?s ?p ?o"
        if(relation_uri.nil?)
          @where_clauses << "?s ?p ?o. FILTER regex(str(?p), \"#{relation}\")"
        else
          @where_clauses << "?s ?p ?o. FILTER(?p = <#{relation_uri}>)"
        end        
      end
    
      @items.each do |entity|
        if entity.is_a? Xpair::Literal
          item_id = entity.to_s
        else
          item_id = Xpair::Namespace.expand_uri(entity.id)
        end
        
        if relation_uri.nil?
          construct_clause = "?s#{@object_index += 1} ?p#{@predicate_index+=1} <#{item_id}>."
          where_clause = "{?s#{@object_index} ?p#{@predicate_index} <#{item_id}>. FILTER regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\").}"
        else
          construct_clause = "?s#{@object_index += 1} <#{relation_uri.to_s}> <#{item_id}>."
          where_clause = "{?s#{@object_index} <#{relation_uri.to_s}> <#{item_id}>.}"
        end  
        construct_clause << " ?s#{@object_index} <#{@label_property}> ?label."
        where_clause <<  " UNION {?s#{@object_index} <#{@label_property}> ?label.}"   
        @construct_clauses << construct_clause
        @where_clauses << where_clause
      end
      self
    end

    def find_relations()
      
      @items.each do |entity|
        @construct_clauses << "<#{entity.to_s}> ?p#{@predicate_index+=1} ?o."
        @where_clauses << "<#{entity.to_s}> ?p#{@predicate_index} ?o."        
      end
      self
    end
    
    def find_backward_relations()
      @items.each do |entity|
        @construct_clauses << "?s ?p#{@predicate_index+=1} <#{entity.to_s}>."
        @where_clauses << "?s ?p#{@predicate_index} <#{entity.to_s}>."        
      end
      self
    end
    
    def find_relations_in_common()
      @items.each do |entity|
        @construct_clauses << "<#{entity.to_s}> ?p ?o#{@object_index +=1}."
        @where_clauses << "<#{entity.to_s}> ?p ?o#{@object_index}."       
      end
      self
    end


    def on(item)
      @items << item
      self
    end
  
    def execute
      hash = {}
      pages = @items.size/650
      
      if empty_query?
        return {}
      end
      labels_by_item = {}
      all_items = []
      if(@items.empty?)
        @server.execute(build_select_query()).each_solution do |solution|
          
          if(solution[:s].nil? && solution[:o].nil?)
            relation = Relation.new(Xpair::Namespace.colapse_uri(solution[:p].to_s))
            relation.add_server(@server)
            hash[relation] = {}
          else
            
            item = Entity.new(Xpair::Namespace.colapse_uri(solution[:s].to_s))
            item.add_server(@server)

            relation = Relation.new(Xpair::Namespace.colapse_uri(solution[:p].to_s))
            relation.add_server(@server)
            hash[item] ||= {}
            hash[item][relation] ||=[]
            # 
            if solution[:o].literal?
              object = convert_literal(solution[:o])
            else
              object = Entity.new(Xpair::Namespace.colapse_uri(solution[:o].to_s))
              object.add_server(@server)
            end

            hash[item][relation] << object
          end
        end
        hash
      else
        build_queries().each do |query|
          @server.execute(query).each_statement do |solution|
            subject_id = Xpair::Namespace.colapse_uri(solution[0].to_s)
            relation_id = Xpair::Namespace.colapse_uri(solution[1].to_s)
            item = Entity.new(subject_id)
            item.add_server(@server)
            if solution[1].to_s == @label_property
              labels_by_item[item] = solution[2].to_s
            else
              relation = Relation.new(relation_id)
              relation.add_server(@server)
       
              hash[item] ||= {}
              hash[item][relation] ||=[]
              # 
              if solution[2].literal?
                object = convert_literal(solution[2])
              else
                object = Entity.new(Xpair::Namespace.colapse_uri(solution[2].to_s))
                object.add_server(@server)
              end
              hash[item][relation] << object
              all_items += [item, relation]
              all_items << object if !object.is_a? Xpair::Literal
            end
          end
        end
        @items.each do |item|
          if(!hash.has_key?(item))
            hash[item] = {}
          end
        end
        all_items.each do |item|
          item.text = labels_by_item[item]
        end
        hash        
      end

    end

    def convert_literal(literal)
      if literal.to_s.match(/\A[-+]?[0-9]+\z/).nil?
        Xpair::Literal.new(literal.to_s)
      else
        Xpair::Literal.new(literal.to_s.to_i)
      end
    end
    
    def build_select_query
      query = "SELECT " << @select_clauses.join(" . ") << build_where()  

      query
    end
    
    def empty_query?
      @select_clauses.empty? && @construct_clauses.empty?
    end
    
    def build_where
      " WHERE{" << @where_clauses.map{|where_clause| "{#{where_clause}}"}.join(" UNION ") << @filters.join(" ") << "}"
    end

    def build_queries
      queries = []
      limit = 300
      pages = @items.size/limit
      pages = 1 if pages < 1
      offset = 0
      while offset < @items.size
        where = " WHERE{" << @where_clauses[offset..limit].map{|where_clause| "{#{where_clause}}"}.join(" UNION ") << @filters.join(" ") << "}"
        query =  "CONSTRUCT{" << @construct_clauses[offset..limit].join(" ") << "}" << where


        queries << query
        offset = limit + 1
        limit += 300
      end      
      queries
    end
  end
end