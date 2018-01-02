require 'forwardable'
require "test/unit"
require "rdf"
require 'linkeddata'
require 'pry'
require './mixins/operation_factory'
require './execution/workflow.rb'
require './mixins/xplain.rb'

require './mixins/enumerable'
require './mixins/relation'
require './exceptions/missing_relation_exception'
require './exceptions/missing_value_exception'
require './exceptions/invalid_input_exception'
require './exceptions/disconnected_operation_exception'
require './exceptions/missing_auxiliary_function_exception'
require './exceptions/numeric_item_required_exception'

require './model/node'
require './model/edge'
require './model/entity'
require './model/literal'
require './model/schema_relation'
require './model/computed_relation'
require './model/path_relation'
require './model/namespace'
require './model/result_set'
require './mixins/model_factory'

require './adapters/filterable'
require './adapters/navigational'
require './adapters/searchable'
require './adapters/data_server'
require './adapters/rdf/cache'
require './adapters/rdf/rdf_navigational'
require './adapters/rdf/sparql_helper'
require './adapters/rdf/rdf_data_server'
require './visualization/visualization'
require 'securerandom'
require './operations/operation'
require './operations/set_operation'


class InputProxy
  attr_accessor :input_nodes
  def initialize(input_nodes = [])
    @input_nodes = input_nodes
  end
  
  def get_level(level)
    if(level == 1)
      root = Node.new("rootProxy")
      root.children = @input_nodes
      return [root]
    elsif(level == 2)
      return @input_nodes
    elsif(level == 3)
      return @input_nodes.map{|n|n.children}.flatten
    end
  end
  
  def count_levels
    nodes = @input_nodes || []
    count = 1
    while !nodes.empty?
      count += 1
      nodes = nodes.map{|node| node.children}.flatten
    end
    return count
  end
  
  def empty?
    @input_nodes.empty?
  end
  
  def copy
    InputProxy.new(@input_nodes.dup)
  end
  
  def leaves()
    @input_nodes
  end
end

class XplainUnitTest < Test::Unit::TestCase
  def setup
    load_papers_server
    load_simple_server
  end

  def load_papers_server
    papers_graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p4")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p7"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p7"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p8"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p8"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p9"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p10"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:submittedTo"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a1") ]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a2") ]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p20"),  RDF::URI("_:author"), RDF::URI("_:a3")]

      graph << [RDF::URI("_:p2"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal2")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), RDF::Literal.new("2005", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), RDF::Literal.new("2010", datatype: RDF::XSD.string)]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2000", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), RDF::Literal.new("1998", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2010", datatype: RDF::XSD.string)]     
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:relevance"), RDF::Literal.new(10, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:relevance"), RDF::Literal.new(20, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:relevance"), RDF::Literal.new(8, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:relevance"), RDF::Literal.new(16, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:relevance"), RDF::Literal.new(5, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:relevance"), RDF::Literal.new(15, datatype: RDF::XSD.int)]
      
    end

    @papers_server = RDFDataServer.new(papers_graph)
    
  end
  
  def load_simple_server
    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      
      graph << [RDF::URI("_:p1"),  RDF::RDFS.label, RDF::Literal('lp1')]
      graph << [RDF::URI("_:p2"),  RDF::RDFS.label, RDF::Literal('lp2')]
      graph << [RDF::URI("_:r1"),  RDF::RDFS.label, RDF::Literal('lr1')]
      graph << [RDF::URI("_:r2"),  RDF::RDFS.label, RDF::Literal('lr2')]
      graph << [RDF::URI("_:o1"),  RDF::RDFS.label, RDF::Literal('lo1')]
      graph << [RDF::URI("_:o2"),  RDF::RDFS.label, RDF::Literal('lo2')]
    end

    @server = RDFDataServer.new(@graph)    
  end
  
  def create_nodes(items)
    items.map{|item| Node.new(item)}
  end
  
end
