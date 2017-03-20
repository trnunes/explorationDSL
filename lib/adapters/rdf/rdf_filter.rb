module SPARQLQuery
  module SPARQLFilter   
    attr_accessor :filters, :where_stmts

  
    def self.next_object_index
      @@object_index ||=0
      @@object_index += 1
    end 
  
    def self.reset_indexes
      @@object_index = 0
    
    end
  
    def initialize(server)
      @server = server
      @filters = []
      @select_clauses = ["?s"]
      @where_stmts = []      
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
    
      @filters << SimpleFilter.new(equals_stmt(entity))
    end
    
    def convert_literal(literal)
      if literal.value.to_s.match(/\A[-+]?[0-9]+\z/).nil?
        "\"" << literal.value << "\""
      else
        literal.value.to_s
      end
    end
  
    def relation_equals(relations, item)

      sparql_entity = ""
      if(item.is_a?(Entity) || item.is_a?(Relation) || item.is_a?(Type))
        sparql_entity = "<#{item.to_s}>"
      else
        if(item.is_a?(String))
          sparql_entity = convert_literal(Xpair::Literal.new(item))
        else
          sparql_entity = convert_literal(item)
        end
      end
      @where_stmts << SimpleFilter.new("?s #{path_string(relations)} #{sparql_entity}")    
    end
    
    def filter_by_range(relations, min, max)
      object_index = SPARQLFilter.next_object_index
      @where_stmts << SimpleFilter.new("?s #{path_string(relations)} ?o#{object_index}")
      @filters << SimpleFilter.new("?o#{object_index} >= #{min.to_s}")
      @filters << SimpleFilter.new("?o#{object_index} <= #{max.to_s}")
    end
  
    def regex(pattern)
      @filters << SimpleFilter.new(regex_stmt(pattern))
    end
    
    def path_string(relations)
      relations.map{|r| "<" << Xpair::Namespace.expand_uri(r.to_s) << ">"}.join("/")
      
    end
    
    def relation_regex(relations, pattern)
      object_index = SPARQLFilter.next_object_index
      
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
    end
  

    def eval     
      result_set = Set.new
      SPARQLFilter.reset_indexes
      @server.execute(build_query).each_solution do |solution|
        result_set << Entity.new(solution[:s].to_s)
      end
      
      result_set
    end
  
    def build_query
      filter_stmt = filter_expression()
      where_stmt = where_expression()
   
      where_stmt = "?s ?p ?o" if where_stmt.empty?
    
      query = "SELECT ?s WHERE{ #{where_stmt}."      
      query << " FILTER(" + filter_stmt + ")." if !filter_stmt.empty?      
      query << "}"
      puts "FILTER QUERY: "
      puts query.to_s
      puts "------------------------------"
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
          @where_stmts.map{|w| w.where_expression}.reject { |c| c.empty? }.join(" . ")
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
          @where_stmts.map{|w| "{#{w.where_expression}}"}.reject { |c| c.empty? }.join(" UNION ")
        end       
      end  
    end
  end
end