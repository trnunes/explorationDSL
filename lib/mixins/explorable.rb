require 'model/entity.rb'
require 'model/relation.rb'
require 'sourcify'
#TODO Separate the generation of the expression from the execution of the operation.
# IDEA: create <operation>(<params>) and <operation>_exec(<params>) methods where the former starts the execution and create the expressions and the later
# only executes the operations.
module Explorable
  attr_accessor :original_set
  attr_accessor :expression  

  def update
    #Reevaluate the expression  
  end  
  
  def union(target_set)
    result = Xset.new("union")
    result.elements = self.elements + target_set.elements
    result.expression = "#{self.expression}.union(#{target_set.expression})"
    result
  end
  
  def intersect(target_set)
    if(target_set.is_a?(Xset))
      target_set = target_set.elements
    end
    result.elements = self.elements & target_set
    result.expression = "#{self.expression}.intersect(#{target_set.expression})"
    result
  end
  
  def pivot(relations)
    if @original_set.nil?
      @original_set = self
    end
    result_set = Xset.new("pivot")
    restricted_domain_pairs = []
    pairs_by_subject_by_relation = {}
    visited = []
    @original_set.each do |pair|
      # 
      # 
      if(pair.second_item.is_a? Relation)
        if pairs_by_subject_by_relation[pair.first_item].nil?
          pairs_by_subject_by_relation[pair.first_item] = {}
        end
        
        if (pairs_by_subject_by_relation[pair.first_item][pair.second_item.first_item].nil?)
          pairs_by_subject_by_relation[pair.first_item][pair.second_item.first_item] = []
        end
        pairs_by_subject_by_relation[pair.first_item][pair.second_item.first_item] << pair.second_item
      end
    end
    # 
    # each do |item|
    #   
    # end
    each do |item|
      if item.relation? && item.second_item.relation?
        item = item.second_item.first_item
      end
      
      next if visited.include?(item)
      
      # if (relations.is_a? XList)
        #TODO implement property paths
      # elsif (relations.is_a? Set)
      
        relations.each do |relation|
          pair_by_subject = pairs_by_subject_by_relation[relation]
          result_set << pair_by_subject[item].map{|r| r.second_item}
        end
        visited << item
      # end
    end
    result_set.original_set = @original_set
    result_set.expression = "#{self.expression}.pivot(#{relations.expression})"
    result_set
  end
  
  #TODO generate the executions with sourcify to generate codes of lambdas  
  #HINTS: 
  #   replacing a variable in a lambda body => sexp = lambda{x + y}.to_sexp.find_and_replace_all(:x, :z)
  #   generating a S-expression tree and back to code => eval(Ruby2Ruby.new.process(lambda{x+y}.to_sexp))
  #   retrieving a binding of a lambda => b = lambda{|item| item == r}.binding
  #   retrieving the context variables => eval("local_variables", b)
  #   retrieving the the value of a bound variable "r" => eval("r", b)
  def refine(*filters)
    result_set = Xset.new("refine")
    filters.each{|f| puts f.to_source}
    filters_proc = filters.map{|filter| filter.to_proc}
    refined_items = self.select do |item|
      # begin
        result = filters_proc.inject(lambda{|item_out| true}) do |f1,f2|         
          lambda{|item_in| f1.call(item_in) && f2.call(item_in)}
        end.call(item)
      # rescue Exception => e
      #   false
      # end
      # 
      result
    end
    result_set.elements = refined_items
    
    filter_expression = ""
    filters.each do |filter|         
      filter_expression += filter.to_source + ","
    end
    filter_expression[filter_expression.length - 1] = ""
    
    result_set.expression = "#{self.expression}.refine(#{filter_expression})"
    result_set    
  end
  
  def group_by(&expr)
    result = Xset.new("group_by")
    groups_hash = {}
    self.each do |item1|
      self.each do |item2|
        if(item1 != item2)
          relations = yield(item1, item2)
          
          if(!relations.nil?)
            if !(relations.is_a?(self.class) || relations.is_a?(Array))
              relations = [relations]
            end
            relations.each do |relation|
              if groups_hash[relation].nil?
                groups_hash[relation] = Xset.new(relation)
              end
              groups_hash[relation] << item1
              groups_hash[relation] << item2
            end
          end
        end
      end
    end
    groups_hash.each{|relation, group| group.uniq!; result << Relation.new(relation, group)}
    result
  end
  
  def correlate(origin, target, max_length = -1)
    paths = Xset.new("correlate " + origin.to_s +  " - " + target.to_s)
    queue = [Xset.new("path", [Relation.new(origin, origin)])]
    exchanged = []
    visited = []
    while !(queue.empty? || (max_length == 0)) do
      max_length -= 1
      current_path = queue.delete(queue.first)
      # 
      # 
      last_node = current_path.last[1]
      # 
      # 
      # 
      if last_node == target
        paths << current_path
      else
        if(visited.include?(last_node))
          next
        end
        inverted = self.find([[nil, last_node]]).map{|pair| Relation.new(pair[1], pair[0])}
        exchanged = exchanged + inverted
        edges = self.find([[last_node, nil]]) + inverted
        # edges = edges.concat(edges.map{|pair| Relation.new(pair.second_item, pair.first_item)})
        
        edges.each{|edge| 
        edges.each do |edge|
          if(!current_path.include?(edge))            
            queue << Xset.new("id", current_path + [edge])
          end          
        end
      end
      visited << last_node
      # 
      # 
    end
    paths.each do |path| 
      path.delete(path.first)
      path.each do |edge|
        if exchanged.include?(edge)
          edge.swap!
        end
      end
    end
    paths.expression = "#{self.expression}.correlate(#{origin.expression},#{target.expression},20)"
    paths 
  end
  
  def find(pattern)
    result = []
    pattern.each do |motif|
      # 
      # 
      result = result.concat(self.select{|item| match(item, motif)})
    end
    return Xset.new("find", result)
  end
  
  def match(pair, motif)
    return false if !pair.is_a?(Relation)

    first_item_motif = motif[0]
    second_item_motif = motif[1]
    # 
    # 
    
    if !first_item_motif.is_a?(Proc)
      if first_item_motif.nil?
        first_item_match = lambda{|item| true}
      else
        first_item_match = lambda do |item|           
          item == first_item_motif           
        end        
      end 
    else
      first_item_match = first_item_motif
    end
    
    if !second_item_motif.is_a?(Proc)
      if second_item_motif.nil?
        second_item_match = lambda{|item| true}
      else
        second_item_match = lambda do |item|           
          item == second_item_motif          
        end
      end
    else
      second_item_match = second_item_motif
    end
    # 
    # 
    if(first_item_match.call(pair.first_item) && second_item_match.call(pair.second_item))
      return true
    end
    
    return false
  end
end