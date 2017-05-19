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
      @cached_solution = Set.new
      
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
    
    def restricted_image(relations)
      @relation = relations
      if(!relations.respond_to? :each)
        @relation = [relations]
      end
      
      
      where_clause = ""
      if(@relation.size > 1)
        where_clause = "?s #{@relation.map{|r| "<" + Xpair::Namespace.expand_uri(r.to_s) + ">"}.join("/")} ?o. VALUES ?s {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. "
      else
        where_clause = "VALUES ?s {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s #{@relation.map{|r| "<" + Xpair::Namespace.expand_uri(r.to_s) + ">"}.join("/")} ?o."
      end
      @query = "SELECT ?s ?o where{#{where_clause}}"
      self
    end

    def restricted_domain(relations)
      @relation = relations
      if(!relations.respond_to? :each)
        @relation = [relations]
      end
      @query = "SELECT ?s ?o where{ VALUES ?o {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s #{@relation.map{|r| "<" + Xpair::Namespace.expand_uri(r.to_s) + ">"}.join("/")} ?o.}"
      self
    end

    
    def find_forward_relations(items)
      @items = items
      @query = "SELECT distinct ?p WHERE{ VALUES ?s {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?p ?o.}"
      results = []
      @server.execute(@query).each do |s|
        results << Xpair::Namespace.colapse_uri(solution[:p].to_s)
      end
      results
    end
    
    
    def find_backward_relations(items)
      @items = items
      @query = "SELECT distinct ?p WHERE{ VALUES ?o {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?p ?o.}"
      results = []
      @server.execute(@query).each do |s|
        results << Xpair::Namespace.colapse_uri(solution[:p].to_s)
      end
      results
    end
    
    def find_relations(items)
      @items = items
      @query = "SELECT distinct ?pf ?pb WHERE{ {VALUES ?o {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?pf ?o.} UNION {VALUES ?s {#{@items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?pb ?o.}}"
      results = Set.new
      @server.execute(@query).each do |s|
        if(!s[:pf].nil?)
          results << SchemaRelation.new(Xpair::Namespace.colapse_uri(s[:pf].to_s), @server, true)
        end
        
        if(!s[:pb].nil?)
          results << SchemaRelation.new(Xpair::Namespace.colapse_uri(s[:pb].to_s), @server)
        end
      end
      results
      
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
      @server.execute(@query).each do |solution|

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
        item.add_server(@server)
        relation = SchemaRelation.new(relation_id, @server)


        hash[item] ||= {}
        hash[item][relation] ||=[]
        # binding.pry
        if(solution[:o])
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
    end
  end
end

