require 'java'

# 'java_import' is used to import java classes
java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'

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
      @subject_index = 0
      
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
    
      @items.each do |entity|
        entity_id = Xpair::Namespace.expand_uri(entity.id)
        if relation_uri.nil?
          construct_clause = "<#{entity_id}> ?p#{@predicate_index += 1} ?o#{@object_index += 1}."
          if @server.use_select
            where_clause = "{?#{@subject_index += 1} ?p#{@predicate_index} ?o#{@object_index}. FILTER regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\") && ?s#{@subject_index} = <#{entity_id}>.}"
          else
            where_clause = "{<#{entity_id}> ?p#{@predicate_index} ?o#{@object_index}. FILTER regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\").}"
          end
          
        else
          construct_clause = "<#{entity_id}> <#{relation_uri.to_s}> ?o#{@object_index += 1}."
          if @server.use_select
            where_clause = "{?s#{@subject_index += 1} ?p#{@predicate_index += 1} ?o#{@object_index}. FILTER(?s#{@subject_index} = <#{entity_id}> && ?p#{@predicate_index} = <#{relation_uri}>)}"
          else
            where_clause = "{<#{entity_id}> <#{relation_uri.to_s}> ?o#{@object_index}.}"
          end
          
        end

        if !@server.label_property.nil?
          construct_clause << " ?o#{@object_index} <#{@server.label_property}> ?label."
          where_clause <<  " UNION {?o#{@object_index} <#{@server.label_property}> ?label.}"
        end
        @construct_clauses << construct_clause
        @where_clauses << where_clause
      end
      self
    end

    def restricted_domain(relation)
    
      relation_uri = search_uri(relation)
      @items.each do |entity|
        if entity.is_a? Xpair::Literal
          item_id = entity.to_s
        else
          item_id = Xpair::Namespace.expand_uri(entity.id)
        end
        
        if relation_uri.nil?
          construct_clause = "?s#{@object_index += 1} ?p#{@predicate_index+=1} <#{item_id}>."

          if @server.use_select

            where_clause = "{?s#{@object_index} ?p#{@predicate_index} ?o#{@subject_index+=1}. FILTER ?o#{@subject_index}=<#{item_id}> && regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\").}"
          else
            
          where_clause = "{?s#{@object_index} ?p#{@predicate_index} <#{item_id}>. FILTER regex(str(?p#{@predicate_index}), \"#{relation.to_s}\", \"i\").}"            
          end
        else
          construct_clause = "?s#{@object_index += 1} <#{relation_uri.to_s}> <#{item_id}>."
          if @server.use_select
            where_clause = "{?s#{@object_index} ?p#{@predicate_index += 1} ?o#{@subject_index += 1}. FILTER(?p#{@predicate_index} = <#{relation_uri.to_s}> && ?o#{@subject_index} = <#{item_id}>)}"
          else
            where_clause = "{?s#{@object_index} <#{relation_uri.to_s}> <#{item_id}>.}"
          end
        end
        if !@server.label_property.nil?
          construct_clause << " ?s#{@object_index} <#{@server.label_property}> ?label."
          where_clause <<  " UNION {?s#{@object_index} <#{@server.label_property}> ?label.}"
        end
        @construct_clauses << construct_clause
        @where_clauses << where_clause
      end
      self
    end

    def find_relations()
      
      @items.each do |entity|
        @construct_clauses << "<#{entity.to_s}> ?p#{@predicate_index+=1} ?o#{@object_index+=1}."
        if @server.use_select
          @where_clauses << "?s#{@subject_index += 1} ?p#{@predicate_index} ?o#{@object_index}. FILTER(?s#{@subject_index} = <#{entity.to_s}>)"
        else
          @where_clauses << "<#{entity.to_s}> ?p#{@predicate_index} ?o#{@object_index}."
        end
      end
      self
    end
    
    def find_backward_relations()
      @items.each do |entity|
        @construct_clauses << "?s#{@subject_index+=1} ?p#{@predicate_index+=1} <#{entity.to_s}>."
        if @server.use_select
          @where_clauses << "?s#{@subject_index} ?p#{@predicate_index} ?#{@object_index+=1}. FILTER(?#{@object_index} = <#{entity.to_s}>)"
        else
          @where_clauses << "?s#{@subject_index} ?p#{@predicate_index} <#{entity.to_s}>."
        end

        
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
        @server.execute(build_select_query(), content_type: "application/sparql-results+xml").each do |solution|

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
              object = @server.build_literal(solution[:o])
            else
              object = Entity.new(Xpair::Namespace.colapse_uri(solution[:o].to_s))
              object.add_server(@server)
            end

            hash[item][relation] << object
          end
        end
        hash
      else
        queries = build_queries()
        
        # build_queries().each do |query|
        #
        #   @server.execute(query).each do |solution|
        #     if(solution.is_a? RDF::Query::Solution)
        #       solution = solution.to_a.map{|s_array| s_array[1]}
        #     end
        #     subject_id = Xpair::Namespace.colapse_uri(solution[0].to_s)
        #     relation_id = Xpair::Namespace.colapse_uri(solution[1].to_s)
        #     item = Entity.new(subject_id)
        #     item.add_server(@server)
        #     if solution[1].to_s == @server.label_property.to_s
        #       labels_by_item[item] = solution[2].to_s
        #     else
        #       relation = Relation.new(relation_id)
        #       relation.add_server(@server)
        #
        #       hash[item] ||= {}
        #       hash[item][relation] ||=[]
        #       #
        #       if solution[2].literal?
        #         object = @server.build_literal(solution[2])
        #       else
        #         object = Entity.new(Xpair::Namespace.colapse_uri(solution[2].to_s))
        #         object.add_server(@server)
        #       end
        #       hash[item][relation] << object
        #       all_items += [item, relation]
        #       all_items << object if !object.is_a? Xpair::Literal
        #     end
        #   end
        # end
                
        executor = ThreadPoolExecutor.new(queries.size, # core_pool_treads
                                          queries.size, # max_pool_threads
                                          10000000000, # keep_alive_time
                                          TimeUnit::SECONDS,
                                          LinkedBlockingQueue.new)
        puts "NUMBER OF THREADS: " << queries.size.to_s
        tasks = []
        parallel_queries = []
        queries.each do |query|
          if(@server.cache.has_key? query)
            # puts "QUERY IN CACHE: " << query
            parallel_query = @server.cache[query]
          else
            parallel_query = ParallelQuery.new(query, @server)
            task = FutureTask.new(parallel_query)
            parallel_query.call()
            executor.execute(task)
            tasks << task            
          end
          parallel_queries << parallel_query
        end
      
        tasks.each do |t|
          t.get
        end
        executor.shutdown()
        
        parallel_queries.each do |p_query|
          @server.cache[p_query.query] = p_query 
          p_query.results.each do |solution|
            if(solution.is_a? RDF::Query::Solution)
              solution = solution.to_a.map{|s_array| s_array[1]}
            end
            subject_id = Xpair::Namespace.colapse_uri(solution[0].to_s)
            relation_id = Xpair::Namespace.colapse_uri(solution[1].to_s)
            item = Entity.new(subject_id)
            item.add_server(@server)
            if solution[1].to_s == @server.label_property.to_s
              labels_by_item[item] = solution[2].to_s
            else
              relation = Relation.new(relation_id)
              relation.add_server(@server)
       
              hash[item] ||= {}
              hash[item][relation] ||=[]
              # 
              if solution[2].literal?
                object = @server.build_literal(solution[2])
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
      local_limit = @server.items_limit
      pages = @items.size/@server.items_limit
      pages = 1 if pages < 1
      offset = 0
      while offset < @items.size
        where = " WHERE{" << @where_clauses[offset..local_limit].map{|where_clause| "{#{where_clause}}"}.join(" UNION ") << @filters.join(" ") << "}"
        if @server.use_select
          query =  "SELECT * " << where
        else
          query =  "CONSTRUCT{" << @construct_clauses[offset..local_limit].join(" ") << "}" << where
        end
        queries << query
        offset = local_limit + 1
        local_limit += @server.items_limit
      end      
      queries
    end
  end
  
  class ParallelQuery
    include Callable
    
    attr_accessor :results, :query
    
    def initialize(query, server)
      @query = query
      @server = server
    end
    
    def call

      @results = @server.execute(@query)

    end
  end
  
end