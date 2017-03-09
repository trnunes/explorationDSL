require "test/unit"
require "rdf"

require './mixins/hash_explorable'
require './mixins/auxiliary_operations'
require './mixins/enumerable'
require './mixins/persistable'
require './filters/filtering'
require './filters/contains'
require './filters/equals'
require './filters/keyword_match'
require './filters/match'
require './filters/in_range'
require './model/item'
require './model/xset'
require './model/entity'
require './model/relation'
require './model/type'
require './model/ranked_set'

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/rdf_filter.rb'
require './adapters/rdf/rdf_nav_query.rb'

$PAGINATE = 10
##TODO BUGS TO CORRECT
## contains_one does not admit literals
##

class EndpointExplorationTest < Test::Unit::TestCase
  def setup
    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r1"), RDF::URI("_:o3")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o4")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o5")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:r2"), RDF::URI("_:o6")]
    end
    
    @server = RDFDataServer.new(@graph)
    
    @correlate_graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:o1"), RDF::URI("_:r1"), RDF::URI("_:p1")]
      graph << [RDF::URI("_:o1"), RDF::URI("_:r1"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:o2"), RDF::URI("_:r1"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p1"), RDF::URI("_:r1"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:o2"), RDF::URI("_:r1"), RDF::URI("_:p2")]
    end
    
    @correlate_server = RDFDataServer.new(@correlate_graph)  
    
    @keyword_refine_graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), "keyword1"]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), "keyword2 keyword 3"]      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r1"), RDF::URI("_:o3")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o4")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o5")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:r2"), RDF::URI("_:o6")]
    end
    
    expected_extension = {
      Entity.new("_:a1") => Set.new([3]),
      Entity.new("_:a2") => Set.new([2])
    }
    
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

      graph << [RDF::URI("_:p2"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal2")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), "2005"]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), "2010"]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), "2000"]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), "1998"]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), "2010"]     
    end

    @papers_server = RDFDataServer.new(papers_graph)
      
  end
  
  def test_get_level
    set = Xset.new do |s|
       s << Relation.new("_:author") 
       s << Relation.new("_:publishedOn")
       s << Relation.new("_:publicationYear")
       s << Relation.new("_:keywords")
       s << Relation.new("_:cite", true)      
    end
    
    expected_items = Set.new([
      Relation.new("_:author"),
      Relation.new("_:publishedOn"),
      Relation.new("_:publicationYear"),
      Relation.new("_:keywords"),
      Relation.new("_:cite", true)
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 1)
  end

  def test_get_level_2
    set = Xset.new do |s|
      s.extension = {
        Relation.new("_:author") => Set.new([Entity.new("_:a1")]),
        Relation.new("_:publishedOn") => Set.new([Entity.new("_:journal1")]),
        Relation.new("_:publicationYear") => Set.new([2000]),
        Relation.new("_:keywords") => Set.new([Entity.new("_:k3")]),
        Relation.new("_:cite", true) => Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])
      }      
    
    end
    expected_items = Set.new([
      Set.new([Entity.new("_:a1")]),
      Set.new([Entity.new("_:journal1")]),
      Set.new([2000]),
      Set.new([Entity.new("_:k3")]),
      Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 2)
    
    expected_items = Set.new([
      Relation.new("_:author"),
      Relation.new("_:publishedOn"),
      Relation.new("_:publicationYear"),
      Relation.new("_:keywords"),
      Relation.new("_:cite", true)
    ])
    assert_equal expected_items, set.get_level([set.extension], 1)
  end
  
  def test_get_level_3
    set = Xset.new do |s|
      s.extension = {
       Entity.new("_:p1")=>{Relation.new("_:author") => Set.new([Entity.new("_:a1")])},
       Entity.new("_:p2")=>{Relation.new("_:publishedOn") => Set.new([Entity.new("_:journal1")])},
       Entity.new("_:p3")=>{Relation.new("_:publicationYear") => Set.new([2000])},
       Entity.new("_:p4")=>{Relation.new("_:keywords") => Set.new([Entity.new("_:k3")])},
       Entity.new("_:p5")=>{Relation.new("_:cite", true) => Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])}
      }      
    
    end
    expected_items = Set.new([
      Entity.new("_:p1"),
      Entity.new("_:p2"),
      Entity.new("_:p3"),
      Entity.new("_:p4"),
      Entity.new("_:p5")
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 1)
    
    expected_items = Set.new([
      Relation.new("_:author"),
      Relation.new("_:publishedOn"),
      Relation.new("_:publicationYear"),
      Relation.new("_:keywords"),
      Relation.new("_:cite", true)
    ])
    assert_equal expected_items, set.get_level([set.extension], 2)
    
    expected_items = Set.new([
      Set.new([Entity.new("_:a1")]),
      Set.new([Entity.new("_:journal1")]),
      Set.new([2000]),
      Set.new([Entity.new("_:k3")]),
      Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 3)
    
  end
  
  def test_get_level_4
    set = Xset.new do |s|
      s.extension = {
       Entity.new("_:p1")=>{Relation.new("_:author") => {Entity.new("_:a1")=>{Relation.new("_:birth")=>Set.new([Entity.new("_:date")])}}},
       Entity.new("_:p2")=>{Relation.new("_:publishedOn") => {Entity.new("_:journal1")=>{Relation.new("_:title")=>Set.new([Entity.new("_:name2")])}}},
      }      
    
    end
    expected_items = Set.new([
      Entity.new("_:p1"),
      Entity.new("_:p2")
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 1)
    
    expected_items = Set.new([
      Relation.new("_:author"),
      Relation.new("_:publishedOn")
    ])
    assert_equal expected_items, set.get_level([set.extension], 2)
    
    expected_items = Set.new([
      Entity.new("_:a1"),
      Entity.new("_:journal1")
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 3)
    
    expected_items = Set.new([
      Relation.new("_:birth"),
      Relation.new("_:title")
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 4)
    
    expected_items = Set.new([
      Set.new([Entity.new("_:date")]),
      Set.new([Entity.new("_:name2")])
    ])
    
    assert_equal expected_items, set.get_level([set.extension], 5)
    
    
    
    
  end
  
  
end