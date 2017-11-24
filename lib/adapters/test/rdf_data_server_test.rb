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
  
  
  def test_restricted_image_single

    p1 = Node.new(Xplain::Entity.new("_:p1", "lp1"))
    o1 = Node.new(Xplain::Entity.new("_:o1", "lo1"))
    o2 = Node.new(Xplain::Entity.new("_:o2", "lo2"))

    p1.children_edges = [Edge.new(p1, o1), Edge.new(p1, o2)]
    
    @server.label_property = RDF::RDFS.label.to_s
    
    restricted_image = @server.restricted_image(restriction: [Xplain::Entity.new("_:p1")], relation: Xplain::SchemaRelation.new(id: "_:r1"))

    expected_results = Set.new([Xplain::Entity.new("_:o1", "lo1"), Xplain::Entity.new("_:o2", "lo2")])
    assert_equal expected_results, Set.new(restricted_image.map{|node| node.item})
    assert_equal Set.new([Edge.new(p1, o1), Edge.new(p1, o2)]), Set.new(restricted_image.map{|node| node.parent_edge})
  end

  def test_restricted_image_multiple

    p1 = Node.new(Xplain::Entity.new("_:p1", "lp1"))
    p2 = Node.new(Xplain::Entity.new("_:p2", "lp2"))
    o1 = Node.new(Xplain::Entity.new("_:o1", "lo1"))
    o2 = Node.new(Xplain::Entity.new("_:o2", "lo2"))

    p1.children_edges = [Edge.new(p1, o1), Edge.new(p1, o2)]
    
    @server.label_property = RDF::RDFS.label.to_s
    
    restricted_image = @server.restricted_image(restriction: [Xplain::Entity.new("_:p1"), Xplain::Entity.new("_:p2")], relation: Xplain::SchemaRelation.new(id: "_:r1"))
    returned_image_items = restricted_image.map{|node| node.item}
    expected_results = [Xplain::Entity.new("_:o1", "lo1"), Xplain::Entity.new("_:o2", "lo2"), Xplain::Entity.new("_:o2", "lo2")]
    assert_equal expected_results, returned_image_items.sort{|i1,i2| i1.to_s<=>i2.to_s}
    assert_equal Set.new([Edge.new(p1, o1), Edge.new(p1, o2), Edge.new(p2, o2)]), Set.new(restricted_image.map{|node| node.parent_edge})
  end

  def test_restricted_domain_single

    p1 = Node.new(Xplain::Entity.new("_:p1", "lp1"))
    p2 = Node.new(Xplain::Entity.new("_:p2", "lp1"))
    p3 = Node.new(Xplain::Entity.new("_:p3", "lp1"))
    o2 = Node.new(Xplain::Entity.new("_:o2", "lo2"))
    
    @server.label_property = RDF::RDFS.label.to_s
    
    restricted_image = @server.restricted_domain(restriction: [Xplain::Entity.new("_:o2")], relation: Xplain::SchemaRelation.new(id: "_:r1"))

    expected_results = Set.new([Xplain::Entity.new("_:p1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])
    assert_equal expected_results, Set.new(restricted_image.map{|node| node.item})

    assert_equal Set.new([Edge.new(p1, o2), Edge.new(p2, o2), Edge.new(p3, o2)]), Set.new(restricted_image.map{|node| node.children_edges}.flatten)
  end
  
  def test_empty
    cite = Xplain::SchemaRelation.new(id: "_:cite")
    res_image = @papers_server.restricted_image(relation: cite, restriction: [Xplain::Entity.new("_:paper2")])
    assert_equal Set.new(), Set.new(res_image.each)
    
    res_image = @papers_server.restricted_image(relation: cite, restriction: [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p4")])
    assert_equal Set.new(), Set.new(res_image.each)
    

    res_dom = @papers_server.restricted_domain(relation: cite, restriction: [Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(res_dom.each)
    
    cite = Xplain::SchemaRelation.new(id: "_:cite", inverse: true)
    res_image = @papers_server.restricted_image(relation: cite, restriction: [Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(res_image.each)
    
  end
  
  def test_restricted_image2
    cite = Xplain::SchemaRelation.new(id: "_:cite")
    res_image = @papers_server.restricted_image(relation: cite, restriction: [Xplain::Entity.new("_:paper1")])    
    assert_equal Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]), Set.new(res_image.map{|n|n.item})
    
    sorted_res = res_image.each.sort{|i1, i2| i1.item.id<=>i2.item.id}

    assert_equal sorted_res.first.parent.item, Xplain::Entity.new("_:paper1")
    assert_equal sorted_res[1].parent.item, Xplain::Entity.new("_:paper1")
    assert_equal sorted_res[2].parent.item, Xplain::Entity.new("_:paper1")
  end
  
  def test_restricted_domain2
    cite = Xplain::SchemaRelation.new(id: "_:cite")
    res_dom = @papers_server.restricted_domain(relation: cite, restriction: [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
    assert_equal Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8")]), Set.new(res_dom.map{|n| n.item})
  end
  
  def test_inverse_restricted_image
    cite = Xplain::SchemaRelation.new(id: "_:cite", inverse: true)
    res_image = @papers_server.restricted_image(relation: cite, restriction: [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")])
    assert_equal Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")]), Set.new(res_image.map{|n| n.item})    
  end
  
  def test_inverse_restricted_domain
    cite = Xplain::SchemaRelation.new(id: "_:cite", inverse: true)
    res_dom = @papers_server.restricted_domain(relation: cite, restriction: [Xplain::Entity.new("_:paper1")])
    assert_equal Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]), Set.new(res_dom.map{|n| n.item})
    
  end

  def test_path_restricted_image
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite"), Xplain::SchemaRelation.new(id: "_:author")])
    res_image = @papers_server.restricted_image(relation: path, restriction: [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")])
    assert_equal Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")]), Set.new(res_image.map{|n| n.item})
  end

  def test_path_restricted_domain
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:publishedOn"), Xplain::SchemaRelation.new(id: "_:releaseYear")])
    res_image = @papers_server.restricted_domain(relation: path, restriction: [Xplain::Literal.new("2005")])
    assert_equal Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")]), Set.new(res_image.map{|n| n.item})
  end
  
  def test_inverse_path_restricted_image
    expected_rs = [Xplain::Entity.new("_:p7"),Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:author", inverse: true), Xplain::SchemaRelation.new(id: "_:cite", inverse: true)])
    res_image = @papers_server.restricted_image(relation: path, restriction: [Xplain::Entity.new("_:a1")])
    assert_equal Set.new(expected_rs), Set.new(res_image.map{|n| n.item})
  end
  
  def test_mixed_path_restricted_image    
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite", inverse: true), Xplain::SchemaRelation.new(id: "_:author")])
    res_image = @papers_server.restricted_image(relation: path, restriction: [Xplain::Entity.new("_:p5")])
    assert_equal Set.new(res_image.map{|n| n.item}), Set.new([Xplain::Entity.new("_:a2")])
  end

  def test_mixed_path_restricted_domain
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite", inverse: true), Xplain::SchemaRelation.new(id: "_:author")])
    res_dom = @papers_server.restricted_domain(relation: path, restriction: [Xplain::Entity.new("_:a1")])
    assert_equal Set.new(res_dom.map{|n| n.item}), Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
  end
  
end