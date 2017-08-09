module SPARQLQuery
  module SPARQLFilter   
    attr_accessor :filters, :where_stmts, :construct_stmts, :entities, :offset, :limit

  
    def self.next_object_index
      @@object_index ||=0
      @@object_index += 1
    end 
    
    def self.object_index
      @@object_index
    end
  
    def self.reset_indexes
      @@object_index = 0
    
    end
  
    def initialize(server)
      @server = server
      @filters = []
      @select_clauses = ["?s"]
      @where_stmts = [] 
      @construct_stmts = []     
      @entities = Set.new
      @labels_by_entity = {}
      @offset = 0
      @limit = 0
    end
  
    def equals_stmt(entity)
       "?s=<#{entity.to_s}>"
    end
  
    def relation_equals_stmt(relation)
      "?p=<#{relation.to_s}>"
    end
  
    def regex_stmt(pattern)
      "regex(str(?s), \"#{pattern.to_s}\", \"i\")"
    end
  
  
    def equals(entity)
      @labels_by_entity[Xpair::Namespace.expand_uri(entity.id)] = entity.text
      @entities << "<#{Xpair::Namespace.expand_uri(entity.id)}>"
      @filters << SimpleFilter.new(equals_stmt(entity))

    end
    
    def compare(relation, comparator, value)
      object_index = SPARQLFilter.next_object_index
      @construct_stmts << "#{path_string(relation)} ?o#{object_index}"
      filter_exp = ""
      
      if(comparator == "in" && value.respond_to?(:each))
        filter_exp = "VALUES ?o#{object_index} {" + value.each_item.map do |item| 
          if(item.is_a? Xpair::Literal)
            "\"#{item.value.to_s}\"^^#{SPARQLQuery.get_literal_type(item)}"
          else
            "<#{Xpair::Namespace.expand_uri(item.id)}>"
          end
        end.join(" ") + "}"
      else
        if(value.is_a? Xpair::Literal)
          filter_exp = "FILTER(#{SPARQLQuery.get_literal_type(value)}(?o#{object_index}) #{comparator.to_s} \"#{value.value.to_s}\"^^#{SPARQLQuery.get_literal_type(value)})"
        else
          filter_exp = "FILTER(?o#{object_index} #{comparator.to_s} <#{Xpair::Namespace.expand_uri(value.id)}>)"
        end
        
      end
      
      @where_stmts << SimpleFilter.new("?s #{path_string(relation)} ?o#{object_index}. #{filter_exp}")
      
    end
    
    
  
    def relation_equals(relations, item)
      

      sparql_entity = ""
      if(item.is_a?(Entity) || item.is_a?(Type))
        sparql_entity = "<#{item.to_s}>"
      else
        if(item.is_a?(String))
          sparql_entity = SPARQLQuery.convert_literal(Xpair::Literal.new(item))
        else
          sparql_entity = SPARQLQuery.convert_literal(item)
        end
      end
      if(relations.size == 1)
        @construct_stmts << "#{path_string(relations)} #{sparql_entity}"
      end
      
      @where_stmts << SimpleFilter.new("?s #{path_string(relations)} #{sparql_entity}") 

    end
    
    def filter_by_range(relations, min, max)
      object_index = SPARQLFilter.next_object_index
      @construct_stmts << "#{path_string(relations)} ?o#{object_index}"
      @where_stmts << SimpleFilter.new("?s #{path_string(relations)} ?o#{object_index}. FILTER(#{SPARQLQuery.get_literal_type(min)}(?o#{object_index}) >= \"#{min.value.to_s}\"^^#{SPARQLQuery.get_literal_type(min)} && #{SPARQLQuery.get_literal_type(max)}(?o#{object_index}) <= \"#{max.value.to_s}\"^^#{SPARQLQuery.get_literal_type(max)})")
      # binding.pry
    end
  
    def regex(pattern)
      
      @filters << SimpleFilter.new(regex_stmt(pattern))
    end
    
    ##TODO normalize this parameter to receive only single relations and not arrays
    def path_string(relations)
      relations = [relations] if(!relations.respond_to?(:each))
      

      relations.map do |r|
        if(r.is_a? PathRelation)
          r.relations.map{|rs| "<" + Xpair::Namespace.expand_uri(rs.id) + ">"}.join("/")
        else
          "<" << Xpair::Namespace.expand_uri(r.to_s) << ">"
        end
      end.join("/")
      
    end
    
    def relation_regex(relations, pattern)
      object_index = SPARQLFilter.next_object_index
      @construct_stmts << "#{path_string(relations)} ?o#{object_index}"
      @where_stmts << SimpleFilter.new("?s #{path_string(relations)} ?o#{object_index}")
      @filters << SimpleFilter.new("regex(str(?o#{object_index}), \"#{pattern.to_s}\", \"i\")")
    end
  
    def union(&block)
      union_filter = ORFilter.new server
      if block_given?
        yield(union_filter)
      else
        raise "Union block should be passed!"
      end
      @where_stmts << union_filter
      @filters << union_filter
      @construct_stmts += union_filter.construct_stmts
      @entities += union_filter.entities
    end
  

    def eval     
      result_set = Set.new
      SPARQLFilter.reset_indexes
      @server.execute(build_query, {offset: @offset, limit: @limit}).each do |solution|

        if(solution.is_a? RDF::Query::Solution)
          e = Entity.new(solution.to_a[0][1].to_s)
        else
          e = Entity.new(solution[0].to_s)
        end

        e.text = @labels_by_entity[Xpair::Namespace.expand_uri(e.id)].to_s
        result_set << e
      end
      result_set
    end
  
    def build_query
      filter_stmt = filter_expression()
      where_stmt = where_expression()

      where_stmt = "?s ?p ?o" if where_stmt == "{}"
      first_stmt = "SELECT ?s"
      
      # if(!@construct_stmts.empty?)
      #   construct_expression = "CONSTRUCT { "
      #   # @entities.each do|item_expr|
      #     @construct_stmts.each do |construct_stmt|
      #       construct_expression += "?s #{construct_stmt}. "
      #     end
      #   # end
      #   construct_expression += "} "
      #   first_stmt = construct_expression
      # end
      # binding.pry
      query = "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> #{first_stmt} WHERE{ #{where_stmt}. VALUES ?s {#{@entities.to_a.join(" ")}} "
      # query << " FILTER(" + filter_stmt + ")." if !filter_stmt.empty?
      query << "}"
      query
    end
  
    class SimpleFilter

      attr_accessor :stmt
      def initialize(statement)
        @stmt = statement

      end
  
      def filter_expression
        stmt
      end
  
      def where_expression
        stmt
      end
  
    end

    class ANDFilter
      include SPARQLFilter
      attr_accessor :server
  
      def where_expression
    
       if @where_stmts.empty?
          ""
        else

          @where_stmts.map{|w| "{" << w.where_expression << "}"}.reject { |c| c == "{}" }.join(" . ")
        end      
   
      end
 
      def filter_expression
        if @filters.empty?
          ""
        else
          
           
          @filters.map{|f| f.filter_expression}.reject { |c| c.empty? }.join(" && ")
          
          
        end      
      end
    end

    class ORFilter
      include SPARQLFilter    
  
      def filter_expression
        if @filters.empty?
          ""
        else
          "(" << @filters.map{|f| f.filter_expression}.join(" || ") << ")"
        end      
      end
  
      def where_expression
        # 
        if @where_stmts.empty?
          ""
        else
          @where_stmts.map{|w| "{" << w.where_expression << "}"}.reject { |c| c == "{}" }.join(" UNION ")
        end       
      end  
    end
  end
end