module Xplain
  #TODO implement a save method tracking updates and also result-set updates
  class Session
    include Xplain::SessionWritable
    include Xplain::SessionReadable
    
    attr_accessor :id, :title, :result_sets, :server
    
    def initialize(session_id, title=nil)
      @id = session_id
      @title = title
      @title ||= session_id.gsub("_", " ")
      @result_sets = []
      @server = Xplain.default_server
    end
    
    def set_server(params)
      if params.is_a? Hash
        klass = params[:class]
        klass = eval(klass) if klass.is_a? String
        @server = klass.new(params)
      else
        @server = params
      end
      
    end
    
    def <<(result_set)
      add_set(result_set)
    end
    
    def add_set(result_set, recursive=true)
      
      resulted_from_array = [result_set]
      #TODO Keep cached in memory
      while !resulted_from_array.empty?
        resulted_from_array.each do |r_from|  
          
          if !@result_sets.map{|r| r.intention.to_ruby_dsl_sum}.include? r_from.intention.to_ruby_dsl_sum
            r_from.save if r_from.id.nil?            
            add_result_set(r_from)
            @result_sets.unshift r_from
            Xplain::memory_cache.session_add_resultset(self, r_from)
          end
        end
        break if !recursive
        resulted_from_array = resulted_from_array.map{|r| r.resulted_from}.flatten(1)
      end
    end
    def empty?
      Xplain::ResultSet.find_by_session(self).empty?
    end
    
    def execute(operation)
      operation.setup_session(self)
      rs = operation.execute()
      self << rs
      rs
    end
    
    def deep_copy
      copied_session = Session.create(title: @title.dup)
      leaves = @result_sets.select do |s1|
        @result_sets.select do |s2|
          input_expressions = s2.intention.inputs.map{|input| input.to_ruby_dsl_sum}
          input_expressions.include? s1.intention.to_ruby_dsl_sum 
        end.empty?
      end
      intention_parser = DSLParser.new
      leaf_operations = leaves.map do |l|
        
         operation = eval(intention_parser.to_ruby(l.intention))
         operation
      end
      leaf_operations.map{|operation| copied_session.execute(operation)}
      
      copied_session
    end
    
    def add_graph(leaves)
      
    end
    
    
    
    def each_result_set_tsorted(options={}, &block)
      if @result_sets.empty?
        @result_sets = Xplain::ResultSet.find_by_session(self, options)
      end
      leaves = @result_sets.select do |s1|
        @result_sets.select do |s2|
          
          input_expressions = s2.intention.inputs.map{|input| input.to_ruby_dsl_sum}
          
          input_expressions.include? s1.intention.to_ruby_dsl_sum 
        end.empty?
      end
      leaves.map{|leaf| self.execute(leaf.intention)}

      iterable = @result_sets
      if options[:exploration_only]
        iterable = @result_sets.select{|s| !s.intention.visual?}
      end
      results = Xplain::ResultSet.topological_sort(iterable)
      
      results.each &block
      
    end
    
  end
end