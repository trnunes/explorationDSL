require 'java'

# 'java_import' is used to import java classes
java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'

module SPARQLQuery
  class NavigationalQuery
    attr_accessor :limit
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
      @cached_solution = Set.new
      @queries = []
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
  
    def accept_property_path?
      true
    end
    
    def mount_label_clause(var, relations, inverse=false)
      relation_id = @relation.map{|r| Xpair::Namespace.expand_uri(r.to_s)}.join("/")
      relation_uri = @relation.map{|r| "<" + Xpair::Namespace.expand_uri(r.to_s) + ">"}.join("/")
      label_clause = ""
      label_relations = []
      if inverse
        label_relations = Xpair::Visualization.domain_label_relations(relation_id)
      else
        label_relations = Xpair::Visualization.image_label_relations(relation_id)
      end
      
      if !label_relations.empty?
        label_clause = SPARQLQuery.label_where_clause(var, label_relations)
      else
        type = @server.sample_type(relation_uri, @items, inverse)
        label_clause = SPARQLQuery.label_where_clause(var, Xpair::Visualization.label_relations_for(type))
      end
      # binding.pry
      label_clause = "OPTIONAL " + label_clause if !label_clause.empty?
      label_clause
    end
    
    def build_values_clause(var, items)
      if(items.first.is_a?(Xpair::Literal))
        "VALUES #{var} {#{items.map{|i| SPARQLQuery.convert_literal(i)}.join(" ")}}"
      else
        "VALUES #{var} {#{items.map{|i| "<" + Xpair::Namespace.expand_uri(i.id) + ">"}.join(" ")}}"
      end
    end
    
    def build_paginated_values_clauses(var, items)
      offset = 0
      
      clauses = []
      # binding.pry
      while offset < items.size
        limit = (items.size > 10000)? 10000 : items.size
        # binding.pry
        clauses << build_values_clause(var, items[offset..(offset+limit)])
        offset += limit
      end
      # binding.pry
      clauses
    end
    
    
    def restricted_image(relations, image_items = [])
      @relation = relations
      

      if(!relations.respond_to? :each)
        @relation = [relations]
      end
      # binding.pry
      
      where_clause = ""
      image_items_values_clause = ""
      if(!image_items.empty?)
        image_items_values_clause = build_values_clause("?o", image_items)
      end

      label_clause = mount_label_clause("?o", @relation)
      relation_uri = @relation.map{|r| "<" + Xpair::Namespace.expand_uri(r.to_s) + ">"}.join("/")
            
      values_clauses = build_paginated_values_clauses("?s", @items)
      @queries += values_clauses.map do |values_clause|
        if(@relation.size > 1)
          where_clause = "{?s #{relation_uri} ?o}. #{values_clause}. #{image_items_values_clause} #{label_clause}"
        else
          where_clause = "#{values_clause}. {?s #{relation_uri} ?o}. #{label_clause} #{image_items_values_clause}"
        end
        "SELECT ?s ?o ?lo where{#{where_clause}}"        
      end
      
      # binding.pry

      self
    end

    def restricted_domain(relations, domain_items = [])
      @relation = relations
      if(!relations.respond_to? :each)
        @relation = [relations]
      end
      where_clause = ""
      domain_items_values_clause = ""
      if(!domain_items.empty?)
        domain_items_values_clause = build_values_clause("?s", domain_items)
      end
      label_clause = mount_label_clause("?s", @relation, true)
      # binding.pry
      values_clauses = build_paginated_values_clauses("?o", @items)
      @queries += values_clauses.map do |value_clause|
        where = "#{domain_items_values_clause} #{value_clause}. ?s #{@relation.map{|r| "<" + Xpair::Namespace.expand_uri(r.to_s) + ">"}.join("/")} ?o. #{label_clause}"
        "SELECT ?s ?o ?ls WHERE{#{where}}"
      end
      self
    end

    
    def find_forward_relations(items)
      @items = items
      @queries << "SELECT distinct ?p WHERE{ VALUES ?s {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?p ?o.}"
      results = []
      @server.execute(@query).each do |s|
        results << Xpair::Namespace.colapse_uri(solution[:p].to_s)
      end
      results
    end
    
    
    def find_backward_relations(items)
      @items = items
      @queries << "SELECT distinct ?p WHERE{ VALUES ?o {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?p ?o.}"
      results = []
      @server.execute(@query).each do |s|
        results << Xpair::Namespace.colapse_uri(solution[:p].to_s)
      end
      results
    end
    
    def find_relations(items)
      @items = items
      are_literals = !@items.empty? && @items[0].is_a?(Xpair::Literal)
      values_clauses_s = build_paginated_values_clauses("?s", @items)
      values_clauses_o = build_paginated_values_clauses("?o", @items)
      # binding.pry
      
      for i in 0..values_clauses_s.size-1
        @queries << 
        if(are_literals)
          "SELECT distinct ?pf WHERE{ {#{values_clauses_o[i]}}. ?s ?pf ?o.}}"
        else
          "SELECT distinct ?pf ?pb WHERE{ {#{values_clauses_o[i]}. ?s ?pf ?o.} UNION {#{values_clauses_s[i]}. ?s ?pb ?o.}}"
        end
      end
      results = Set.new
      # binding.pry
      @queries.each do |query|
        @server.execute(query).each do |s|
          if(!s[:pf].nil?)
            results << SchemaRelation.new(Xpair::Namespace.colapse_uri(s[:pf].to_s), true, @server)
          end
        
          if(!s[:pb].nil?)
            results << SchemaRelation.new(Xpair::Namespace.colapse_uri(s[:pb].to_s), false, @server)
          end
        end
      end
      # binding.pry
      results.sort{|r1, r2| r1.to_s <=> r2.to_s}
      
    end
    
    def find_relations_in_common()
      self
    end


    def on(item)
      @items << item
      self
    end
  
    def execute(cache_subject_only = false, subject_modifier="")
      hash = {}
      puts "BEGIN EXECUTE"
      
      @queries.each do |query|
        if @limit
          query << "limit " + @limit.to_s
        end
        @server.execute(query).each do |solution|

          # binding.pry
          subject_id = Xpair::Namespace.colapse_uri(solution[:s].to_s)
          if(solution[:p].nil?)
            if(@relation.is_a?(Array))
              relation_id = @relation.map{|r| r.to_s}.join("/")
            else
              relation_id = @relation.to_s
            end
          else
            relation_id = Xpair::Namespace.colapse_uri(solution[:p].to_s)
          end
          item = Entity.new(subject_id)
          item.text = solution[:ls].to_s
          item.add_server(@server)
          relation = SchemaRelation.new(relation_id, false, @server)


          hash[item] ||= {}
          hash[item][relation] ||=[]
          # binding.pry
          if(solution[:o])
            if solution[:o].literal?
              object = @server.build_literal(solution[:o])
            else
              object = Entity.new(Xpair::Namespace.colapse_uri(solution[:o].to_s))
              object.type = "rdfs:Resource"
              object.text = solution[:lo].to_s
              object.add_server(@server)
            end
            hash[item][relation] << object
          end

        end
      end
      puts "FINISHED EXECUTE"
      hash      
    end
  end
end

