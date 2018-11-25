require 'forwardable'
require "test/unit"
require "rdf"
require 'linkeddata'
require 'pry'
require './mixins/enumerable'
require './mixins/relation'

require './model/node'
require './model/edge'
require './model/entity'
require './model/literal'
require './model/schema_relation'
require './model/path_relation'
require './model/namespace'
require './mixins/model_factory'

require './filters/filter_factory'
require './filters/filtering'

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



class RDFDataServerTest < Test::Unit::TestCase

  def setup

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
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), RDF::Literal.new(2000, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), RDF::Literal.new(1998, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), RDF::Literal.new(2010, datatype: RDF::XSD.int)]     
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:relevance"), RDF::Literal.new(10, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:relevance"), RDF::Literal.new(20, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:relevance"), RDF::Literal.new(8, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:relevance"), RDF::Literal.new(16, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:relevance"), RDF::Literal.new(5, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:relevance"), RDF::Literal.new(15, datatype: RDF::XSD.int)]
            
      
    end

    @papers_server = RDFDataServer.new(papers_graph)

  end

  def create_nodes(items)
    items.map{|item| Node.new(item)}
  end

  def test_sum_by_single_relation_0
    input_items = create_nodes [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")]
    rs = @papers_server.sum(input_items, Xplain::SchemaRelation.new(id: "_:relevance", server: @papers_server))
    
    assert_equal [], rs
  end
  
  def test_sum_by_not_number
    input_items = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]

    rs = @papers_server.sum(input_items, Xplain::SchemaRelation.new(id: "_:cite", server: @papers_server))
    assert_true rs.empty?
  end
  
  def test_sum_single_relation
    input_items = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    rs = @papers_server.sum(input_items, Xplain::SchemaRelation.new(id: "_:relevance", server: @papers_server))

    assert_equal Set.new([Xplain::Literal.new(20), Xplain::Literal.new(24), Xplain::Literal.new(30)]), Set.new(rs.children.map{|n| n.children}.flatten.map{|i|i.item})
    
    rs.children.map!{|node| node.children}.flatten!
    assert_equal Set.new([rs[0].parent.item, rs[1].parent.item, rs[2].parent.item]), Set.new([Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])
    
  end
  
  def test_count_by_single_relation_with_restriction
    input_items = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")]
    rs = @papers_server.count(input_items, Xplain::SchemaRelation.new(id: "_:cite", server: @papers_server), [Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")])
    assert_equal [Xplain::Literal.new(2), Xplain::Literal.new(2)], rs.children.map{|n| n.children}.flatten.map{|i|i.item}
    rs.children.map!{|node| node.children}.flatten!

    assert_equal Set.new([rs[0].parent.item, rs[1].parent.item]), Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")])
  end

  def test_count_by_single_relation
    input_items = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")]
    rs = @papers_server.count(input_items, Xplain::SchemaRelation.new(id: "_:cite", server: @papers_server))
    assert_equal [Xplain::Literal.new(3), Xplain::Literal.new(3)], rs.children.map{|n| n.children}.flatten.map{|i|i.item}
    rs.children.map!{|node| node.children}.flatten!

    assert_equal Set.new([rs[0].parent.item, rs[1].parent.item]), Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")])
  end

  def test_count_by_inverse_relation
    input_items = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")]
    
    rs = @papers_server.count(input_items, Xplain::SchemaRelation.new(id: "_:cite", inverse: true, server: @papers_server))
    assert_equal Set.new([Xplain::Literal.new(2), Xplain::Literal.new(4)]), Set.new(rs.children.map{|n| n.children}.flatten.map{|i|i.item})

    rs.children.map!{|node| node.children}.flatten!
    assert_equal Set.new([rs[0].parent.item, rs[1].parent.item]), Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])
  end
  
  def test_average
    input_items = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    rs = @papers_server.avg(input_items, Xplain::SchemaRelation.new(id: "_:relevance", server: @papers_server))
    assert_equal Set.new([Xplain::Literal.new(15.0), Xplain::Literal.new(12.0), Xplain::Literal.new(10.0)]), Set.new(rs.children.map{|n| n.children}.flatten.map{|i|i.item})
    rs.children.map!{|node| node.children}.flatten!
    assert_equal Set.new([rs[0].parent.item, rs[1].parent.item, rs[2].parent.item]), Set.new([Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])
  end
  
  # def test_sum_with_restriction
  #   input_items = [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
  #   rs = @papers_server.sum(input_items, Xplain::SchemaRelation.new(id: "_:relevance"), [Xplain::Literal.new(20), Xplain::Literal.new(8), Xplain::Literal.new(15)])
  #
  #   assert_equal Set.new([Xplain::Literal.new(15), Xplain::Literal.new(24), Xplain::Literal.new(20)]), Set.new(rs.children.map{|n| n.children}.flatten.map{|i|i.item})
  #
  #   rs.children.map!{|node| node.children}.flatten!
  #   assert_equal Set.new([rs[0].parent.item, rs[1].parent.item, rs[2].parent.item]), Set.new([Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])
  #
  # end
end