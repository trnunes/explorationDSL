require 'java'

# 'java_import' is used to import java classes
java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'

module RDFNavigational
  
  attr_accessor :limit, :offset
  
  def self.included klass
     klass.class_eval do
       include SPARQLHelper
     end
  end
   
  def accept_path_clause?
    false
  end
  
  def restricted_image(args)
    restriction_items = args[:restriction].map{|node|node.item} || [] 
    relation = args[:relation] || nil
    image_filter_items = args[:image_filter] || []
          
    where_clause = ""
    relation_uri = parse_item(relation)
    subject_values_clause = 
    if(relation.is_a?(Xplain::PathRelation) && relation.size > 1)

      where_clause = "{#{path_clause(relation)}}. #{values_clause("?s", restriction_items)} #{values_clause("?o", image_filter_items)} #{mount_label_clause("?o", restriction_items, relation)}"
    else
      where_clause = "#{values_clause("?s", restriction_items)} {#{path_clause(relation)}}. #{mount_label_clause("?o", restriction_items, relation)} #{values_clause("?o", image_filter_items)}"
    end

    query = "SELECT ?s ?o ?lo where{#{where_clause} #{path_clause_as_subselect(relation, values_clause("?s", restriction_items), "?o", args[:limit], args[:offset])}}"
    query = insert_order_by_subject(query)

    get_results(query, relation).map{|domain_node| domain_node.children}.flatten
  end

  def restricted_domain(args)
    restriction_items = args[:restriction].map{|node|node.item} || [] 
    relation = args[:relation] || nil
    domain_items = args[:domain_filter] || []
    
    label_clause = mount_label_clause("?s", restriction_items, relation)

    where = "#{path_clause(relation)}. #{label_clause}"
    if(!domain_items.empty?)
      where = "#{values_clause("?s", domain_items)}" << where
    end

    query = "SELECT ?s ?o ?ls WHERE{#{where}  #{values_clause("?o", restriction_items)} #{path_clause_as_subselect(relation, values_clause("?o", restriction_items) + values_clause("?s", domain_items), "?s", args[:limit], args[:offset])}}"
    query = insert_order_by_subject(query)
    
    get_results(query, relation)
  end

  
  def find_forward_relations(items)

    query = "SELECT distinct ?p WHERE{ VALUES ?s {#{items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?p ?o.}"
    results = []
    
    execute(query).each do |s|
      results << Xpair::Namespace.colapse_uri(solution[:p].to_s)
    end
    results
  end
  
  
  def find_backward_relations(items)

    query = "SELECT distinct ?p WHERE{ VALUES ?o {#{items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?p ?o.}"
    results = []
    execute(query).each do |s|
      results << Xplain::Namespace.colapse_uri(solution[:p].to_s)
    end
    results
  end
  
  def find_relations(items)

    are_literals = !items.empty? && items[0].is_a?(Xplain::Literal)
    if(are_literals)
      query = "SELECT distinct ?pf WHERE{ {VALUES ?o {#{items.map{|i| convert_literal(i)}.join(" ")}}. ?s ?pf ?o.}}"
    else
      query = "SELECT distinct ?pf ?pb WHERE{ {VALUES ?o {#{items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?pf ?o.} UNION {VALUES ?s {#{items.map{|i| "<" + i.id + ">"}.join(" ")}}. ?s ?pb ?o.}}"
    end
    
    results = Set.new
    execute(query).each do |s|
      if(!s[:pf].nil?)
        results << Xplain::SchemaRelation.new(Xplain::Namespace.colapse_uri(s[:pf].to_s), true, self)
      end
      
      if(!s[:pb].nil?)
        results << Xplain::SchemaRelation.new(Xplain::Namespace.colapse_uri(s[:pb].to_s), false, self)
      end
    end
    results.sort{|r1, r2| r1.to_s <=> r2.to_s}
    
  end
end

