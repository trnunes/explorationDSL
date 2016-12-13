module SPARQLQuery
  class NavigationalQuery
  
    def initialize(server)
      @items = []
      @server = server
      @construct_clauses = "Construct{ "
      @where_clauses = []
      @select_clauses = []
      @filters = []
      @object_index = 0
      @predicate_index = 0
      @relation_object_hash = {}
    end
  
    def search_uri(relation)
      relation_uri = nil
      RDF::Vocabulary.each do |v|
        begin
          # 
          if v.properties.include?(v[relation.to_s])
            relation_uri = v[relation.to_s].to_s
          end
        rescue KeyError => e
          # 
          relation_uri = nil
        end
      end
      relation_uri
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
        if relation_uri.nil?
          @construct_clauses += "<#{entity.to_s}> ?p#{@predicate_index += 1} ?o#{@object_index += 1}."
          @where_clauses << "<#{entity.to_s}> ?p#{@predicate_index} ?o#{@object_index}. FILTER regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\")."
        else
          @construct_clauses += "<#{entity.to_s}> <#{relation_uri.to_s}> ?o#{@object_index += 1}."
          @where_clauses << "<#{entity.to_s}> <#{relation_uri.to_s}> ?o#{@object_index}."
        end
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
        if relation_uri.nil?
          @construct_clauses += "?s#{@object_index += 1} ?p#{@predicate_index+=1} <#{entity.to_s}>."
          @where_clauses << "?s#{@object_index} ?p#{@predicate_index} <#{entity.to_s}>. FILTER regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\")."
        else
          @construct_clauses += "?s#{@object_index += 1} <#{relation_uri.to_s}> <#{entity.to_s}>."
          @where_clauses << "?s#{@object_index} <#{relation_uri.to_s}> <#{entity.to_s}>."
        end      
      end
      self
    end

    def find_relations()
      if @items.empty?
        @select_clauses << "distinct ?p"
        @where_clauses << "?s ?p ?o."
        
      end
      
      @items.each do |entity|
        @construct_clauses += "<#{entity.to_s}> ?p#{@predicate_index+=1} ?o."
        @where_clauses << "<#{entity.to_s}> ?p#{@predicate_index} ?o."        
      end
      self
    end


    def on(item)
      @items << item
      self
    end
  
    def execute
      hash = {}
      
      if(@items.empty?)
        @server.execute(build_select_query()).each_solution do |solution|
          if(solution[:s].nil? && solution[:o].nil?)
            hash[solution[:p].to_s] = {Entity.new(solution[:p].to_s) => Set.new([])}
          else
            hash[Entity.new(solution[:s].to_s)] ||= {}
            hash[Entity.new(solution[:s].to_s)][Entity.new(solution[:p].to_s)] ||=[]
            # 
            if solution[:o].literal?
              object = convert_literal(solution[:o])
            else
              object = Entity.new(solution[:o].to_s)
            end

            hash[Entity.new(solution[:s].to_s)][Entity.new(solution[:p].to_s)] << object
          end
        end
        @items.each do |item|
          if(!hash.has_key?(item))
            hash[item] = {}
          end
        end
        hash
      else
        @server.execute(build_query()).each_statement do |solution|
       
          hash[Entity.new(solution[0].to_s)] ||= {}
          hash[Entity.new(solution[0].to_s)][Entity.new(solution[1].to_s)] ||=[]
          # 
          if solution[2].literal?
            object = convert_literal(solution[2])
          else
            object = Entity.new(solution[2].to_s)
          end

          hash[Entity.new(solution[0].to_s)][Entity.new(solution[1].to_s)] << object
        end
        @items.each do |item|
          if(!hash.has_key?(item))
            hash[item] = {}
          end
        end
        hash        
      end

    end

    def convert_literal(literal)
      if literal.to_s.match(/\A[-+]?[0-9]+\z/).nil?
        literal.to_s
      else
        literal.to_s.to_i
      end
    end
    
    def build_select_query
      query = "SELECT " << @select_clauses.join(" . ") << build_where()  
      
      query
    end
    
    def build_where
      " WHERE{" << @where_clauses.map{|where_clause| "{#{where_clause}}"}.join(" UNION ") << @filters.join(" ") << "}"
    end

    def build_query
      query =  @construct_clauses << "}" << build_where()      
      query
    end
  end
end