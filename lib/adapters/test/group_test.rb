require 'forwardable'
require "test/unit"
require "rdf"
require 'linkeddata'
require 'pry'
require './mixins/enumerable'
require './mixins/relation'
require './exceptions/missing_relation_exception'

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
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2000", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), RDF::Literal.new("1998", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2010", datatype: RDF::XSD.string)]     
    end

    @papers_server = RDFDataServer.new(papers_graph)

  end
  def create_nodes(items)
    items.map{|item| Node.new(item)}
  end
  
  def test_group_by_empty_relation
    input_items = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2")]
    begin
      rs = @papers_server.group_by(input_items, nil)
      assert false, rs.inspect
    rescue MissingRelationException => e
      assert true, e.to_s
      return
    end
    assert false
  end
  
  def test_group_by_empty_input_set
    rs = @papers_server.group_by([], Xplain::SchemaRelation.new(id: "_:author"))
    assert_true rs.empty?, rs.inspect
  end
  
  def test_group_by_single_relation
    input_items = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"),Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6") ]
    author_relation = Xplain::SchemaRelation.new(id: "_:author", inverse: true)
    rs = @papers_server.group_by(input_items, Xplain::SchemaRelation.new(id: "_:author"))
    # binding.pry
    assert_equal Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")]), Set.new(rs.map{|node| node.item})
 
    a1 = rs.select{|g| g.item.id == "_:a1"}.first
    a2 = rs.select{|g| g.item.id == "_:a2"}.first
    
    assert_equal [author_relation], a1.children.map{|c| c.item}
    assert_equal [author_relation], a2.children.map{|c| c.item}
    
    author_relation_a1 = a1.children.first
    author_relation_a2 = a2.children.first

    a1_children = author_relation_a1.children.map{|c| c.item}.sort{|i1,i2| i1.to_s <=> i2.to_s}
    a2_children = author_relation_a2.children.map{|c| c.item}.sort{|i1,i2| i1.to_s <=> i2.to_s}
    
    assert_equal [Xplain::Entity.new("_:p2"),Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:paper1")], a1_children
    assert_equal [Xplain::Entity.new("_:p3"),Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")], a2_children
  end
  
  def test_group_by_inverse_relation
    input_items = create_nodes [Xplain::Entity.new("_:k1"), Xplain::Entity.new("_:k2"), Xplain::Entity.new("_:k3")]
    
    keywords_relation = Xplain::SchemaRelation.new(id: "_:keywords")
    rs = @papers_server.group_by(input_items, Xplain::SchemaRelation.new(id: "_:keywords", inverse: true))
    # binding.pry
    assert_equal Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p5")]), Set.new(rs.map{|node| node.item})

    p1 = rs.select{|g| g.item.id == "_:paper1"}.first
    p2 = rs.select{|g| g.item.id == "_:p2"}.first
    p3 = rs.select{|g| g.item.id == "_:p3"}.first
    p5 = rs.select{|g| g.item.id == "_:p5"}.first
    # binding.pry
    assert_equal [keywords_relation], p1.children.map{|c| c.item}
    assert_equal [keywords_relation], p2.children.map{|c| c.item}
    assert_equal [keywords_relation], p3.children.map{|c| c.item}
    assert_equal [keywords_relation], p5.children.map{|c| c.item}
    
    assert_equal Set.new([Xplain::Entity.new("_:k1"), Xplain::Entity.new("_:k2"), Xplain::Entity.new("_:k3")]), Set.new(p1.children.first.children.map{|c|c.item})
    assert_equal Set.new([Xplain::Entity.new("_:k3")]), Set.new(p2.children.first.children.map{|c|c.item})
    assert_equal Set.new([Xplain::Entity.new("_:k2")]), Set.new(p3.children.first.children.map{|c|c.item})
    assert_equal Set.new([Xplain::Entity.new("_:k1")]), Set.new(p5.children.first.children.map{|c|c.item})
  end
  
  def test_group_by_path_relation
    input_items = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:publishedOn"), Xplain::SchemaRelation.new(id: "_:releaseYear")])
    inverse_path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:publishedOn", inverse: true), Xplain::SchemaRelation.new(id: "_:releaseYear", inverse: true)])

    rs = @papers_server.group_by(input_items, path)

    assert_equal Set.new([Xplain::Literal.new(2005), Xplain::Literal.new(2010)]), Set.new(rs.map{|node| node.item})

    l2005 = rs.select{|g| g.item.value == 2005}.first
    l2010 = rs.select{|g| g.item.value == 2010}.first
    
    assert_equal [inverse_path], l2005.children.map{|c| c.item}
    assert_equal [inverse_path], l2010.children.map{|c| c.item}
    
    assert_equal Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")]), Set.new(l2005.children.first.children.map{|c|c.item})
    assert_equal Set.new([Xplain::Entity.new("_:p3")]), Set.new(l2010.children.first.children.map{|c|c.item})
  end
  
  def test_group_by_inverse_path_relation
    input_items = create_nodes [Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:author", inverse: true), Xplain::SchemaRelation.new(id: "_:cite", inverse: true)])
    inverse_path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:author"), Xplain::SchemaRelation.new(id: "_:cite")])

    rs = @papers_server.group_by(input_items, path)

    expected_groups = Set.new([Xplain::Entity.new("_:p7"),Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")])
    assert_equal expected_groups, Set.new(rs.map{|node| node.item})
    
    p7 = rs.select{|g| g.item.id == "_:p7"}.first
    p8 = rs.select{|g| g.item.id == "_:p8"}.first
    p9 = rs.select{|g| g.item.id == "_:p9"}.first
    p10 = rs.select{|g| g.item.id == "_:p10"}.first
    p6 = rs.select{|g| g.item.id == "_:p6"}.first
    paper1 = rs.select{|g| g.item.id == "_:paper1"}.first
    
    
    assert_equal [inverse_path], p7.children.map{|c| c.item}
    assert_equal [inverse_path], p8.children.map{|c| c.item}
    assert_equal [inverse_path], p9.children.map{|c| c.item}
    assert_equal [inverse_path], p10.children.map{|c| c.item}
    assert_equal [inverse_path], p6.children.map{|c| c.item}
    assert_equal [inverse_path], paper1.children.map{|c| c.item}
     

    assert_equal p6.children.first.children.size, 2
    assert_equal Set.new(p6.children.first.children.map{|node| node.item.id}), Set.new(["_:a1", "_:a2"])
    
  end
  
  def test_group_by_mixed_path
    input_items = create_nodes [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite", inverse: true), Xplain::SchemaRelation.new(id: "_:author")])
    inverse_path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite"), Xplain::SchemaRelation.new(id: "_:author", inverse: true)])

    rs = @papers_server.group_by(input_items, path)
    
    assert_equal Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")]), Set.new(rs.map{|node| node.item})
    a1 = rs.select{|g| g.item.id == "_:a1"}.first
    a2 = rs.select{|g| g.item.id == "_:a2"}.first
    
    assert_equal [inverse_path], a1.children.map{|c| c.item}
    assert_equal [inverse_path], a2.children.map{|c| c.item}
    
    assert_equal Set.new(a1.children.first.children.map{|node| node.item.id}), Set.new(["_:p3", "_:p4"])
    assert_equal Set.new(a2.children.first.children.map{|node| node.item.id}), Set.new(["_:p5", "_:p3", "_:p4"])
  end
  

end