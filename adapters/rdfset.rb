require 'rdf'
require 'linkeddata'
require 'rdf/ntriples'

require './model/xset.rb'

class RdfSet < Xset
    
  def initialize(graph_uri)
    super(graph_uri)
    puts "graph: " + graph_uri
    @graph = RDF::Graph.load(graph_uri) if !graph_uri.nil?
  end
  
  def elements
    each
  end
  
  def each(&block)
    @elements = []
    @graph.each do |stmt|
      puts stmt.inspect
      object = stmt.object.literal? ? stmt.object.value : Entity.new(stmt.object.to_s)
      relation = Relation.new(Entity.new(stmt.predicate.to_s), Relation.new(Entity.new(stmt.subject.to_s), object))

      if block_given?
        yield relation.second_item
        yield relation
      else
        @elements << relation
        @elements << relation.second_item
      end
    end
    @elements
  end
  
  def map(&block)
    result = []      
    if block_given?
      each{|pair| result.push(yield(pair))}
      result
    else
      each
    end
  end

  def select(&block)
    result = []      
    if block_given?
      each{|pair| result << pair if yield pair}
      result
    else
      each
    end
  end    
end  


# graph = RDF::Graph.load("http://dbpedia.org/resource/Elvis_Presley")
# set = Repository::RDFSet.new(graph)
# set.each{|pair| puts pair.to_s; puts}
# elements = set.each
# puts