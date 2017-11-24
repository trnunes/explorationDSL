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
require './adapters/rdf/filter_interpreter'
require './adapters/rdf/rdf_data_server'
require './visualization/visualization'
require 'securerandom'



class FilterTest < Test::Unit::TestCase

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
  
  def test_filter_empty_input
    input_nodes = []
    f = Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2"))

    rs = @papers_server.filter(input_nodes, f)
    
    assert_true rs.empty?, rs.inspect
  end
  
  def test_filter_empty_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    begin
      f = Xplain::Filtering::Equals.new(nil, Xplain::Entity.new("_:p2"))
    rescue Exception => e
      assert true
      return
    end
    assert false
  end
  
  def test_filter_empty_value
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    begin
      f = Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), nil)
    rescue Exception => e
      assert true
      return
    end
    assert false
    
  end
  
  def test_and_less_than_2
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    
    f = Xplain::Filtering::And.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2"))
    ])

    rs = @papers_server.filter(input_nodes, f)
    
    assert_equal [Xplain::Entity.new("_:paper1")], rs.map{|n|n.item}
    
  end
  
  def test_or_less_than_2
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    
    f = Xplain::Filtering::Or.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2"))
    ])

    rs = @papers_server.filter(input_nodes, f)
    
    assert_equal [Xplain::Entity.new("_:paper1")], rs.map{|n|n.item}
    
  end

  def test_filter_equal
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    f = Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2"))

    rs = @papers_server.filter(input_nodes, f)
    
    assert_equal [Xplain::Entity.new("_:paper1")], rs.map{|n|n.item}
  end
  
  
  def test_filter_equal_literal
    input_nodes = create_nodes [Xplain::Entity.new("_:journal2"), Xplain::Entity.new("_:journal1")]
    f = Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:releaseYear"), Xplain::Literal.new("2005"))

    rs = @papers_server.filter(input_nodes, f)
    
    assert_equal [Xplain::Entity.new("_:journal1")], rs.map{|n|n.item}
  end

  def test_filter_equal_literal_OR_same_relation
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8")
    ]
    
    f = Xplain::Filtering::Or.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p3"))
    ])
    rs = @papers_server.filter(input_nodes, f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end

  def test_filter_equal_literal_OR_different_relation
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p5")
    ]
    
    f = Xplain::Filtering::Or.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a1"))
    ])
    rs = @papers_server.filter(input_nodes, f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  

  def test_filter_equal_literal_AND_same_relation
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p5")
    ]
    
    f = Xplain::Filtering::And.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a1")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a2"))
    ])
    rs = @papers_server.filter(input_nodes, f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end

  def test_filter_equal_literal_AND_different_relation
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")
    ]
    
    f = Xplain::Filtering::And.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a2"))
    ])
    rs = @papers_server.filter(input_nodes, f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  
  def test_filter_property_path
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")
    ]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:publishedOn"), Xplain::SchemaRelation.new(id: "_:releaseYear")])
    
    f = Xplain::Filtering::Equals.new(path, Xplain::Literal.new("2005"))
      
    rs = @papers_server.filter(input_nodes, f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  
  def test_filter_inverse_property_path
    input_nodes = create_nodes [
      Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2"), 
      Xplain::Entity.new("_:a3"), Xplain::Entity.new("_:a4")
    ]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")
    ]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:author", inverse: true), Xplain::SchemaRelation.new(id: "_:cite", inverse: true)])
    
    f = Xplain::Filtering::Equals.new(path, Xplain::Entity.new("_:p10"))
    
    rs = @papers_server.filter(input_nodes, f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  
  def test_filter_mixed_property_path
    input_nodes = create_nodes [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")
    ]
    
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite", inverse: true), Xplain::SchemaRelation.new(id: "_:author")])
    f = Xplain::Filtering::Equals.new(path, Xplain::Entity.new("_:a1"))

    rs = @papers_server.filter(input_nodes, f)
        
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})    
  end
  
  def test_dataset_filter_equal
    f = Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2"))
    rs = @papers_server.dataset_filter(f)
    assert_equal [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")], rs.map{|n|n.item}
  end
  
  
  def test_dataset_filter_equal_literal
    f = Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:releaseYear"), Xplain::Literal.new("2005"))

    rs = @papers_server.dataset_filter(f)
    
    assert_equal [Xplain::Entity.new("_:journal1")], rs.map{|n|n.item}
  end

  def test_dataset_filter_equal_literal_OR_same_relation
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8")
    ]
    
    f = Xplain::Filtering::Or.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p3"))
    ])
    rs = @papers_server.dataset_filter(f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end

  def test_dataset_filter_equal_literal_OR_different_relation
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p5")
    ]
    
    f = Xplain::Filtering::Or.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a1"))
    ])
    rs = @papers_server.dataset_filter(f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  

  def test_dataset_filter_equal_literal_AND_same_relation
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p5")
    ]
    
    f = Xplain::Filtering::And.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a1")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a2"))
    ])
    rs = @papers_server.dataset_filter(f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end

  def test_dataset_filter_equal_literal_AND_different_relation
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")
    ]
    
    f = Xplain::Filtering::And.new([
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:cite"), Xplain::Entity.new("_:p2")),
      Xplain::Filtering::Equals.new(Xplain::SchemaRelation.new(id: "_:author"), Xplain::Entity.new("_:a2"))
    ])
    rs = @papers_server.dataset_filter(f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  
  def test_dataset_filter_property_path
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")
    ]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:publishedOn"), Xplain::SchemaRelation.new(id: "_:releaseYear")])
    
    f = Xplain::Filtering::Equals.new(path, Xplain::Literal.new("2005"))
      
    rs = @papers_server.dataset_filter(f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  
  def test_dataset_filter_inverse_property_path
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")
    ]
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:author", inverse: true), Xplain::SchemaRelation.new(id: "_:cite", inverse: true)])
    
    f = Xplain::Filtering::Equals.new(path, Xplain::Entity.new("_:p10"))
    
    rs = @papers_server.dataset_filter(f)
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})
  end
  
  def test_dataset_filter_mixed_property_path
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p2")
    ]
    
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite", inverse: true), Xplain::SchemaRelation.new(id: "_:author")])
    f = Xplain::Filtering::Equals.new(path, Xplain::Entity.new("_:a1"))

    rs = @papers_server.dataset_filter(f)
        
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(rs.map{|n|n.item})    
  end 

end