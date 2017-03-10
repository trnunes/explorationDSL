require './test/xpair_unit_test'

class GraphTest < XpairUnitTest

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
  
  
  def test_all_parents_2
    set = Xset.new do |s|
      s.extension = {
        Relation.new("_:author") => Set.new([Entity.new("_:a1")]),
        Relation.new("_:publishedOn") => Set.new([Entity.new("_:journal1")]),
        Relation.new("_:publicationYear") => Set.new([Literal.new(2000)]),
        Relation.new("_:keywords") => Set.new([Entity.new("_:k3")]),
        Relation.new("_:cite", true) => Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])
      }      
    
    end
    
    assert_equal Set.new([Relation.new("_:cite", true)]), set.get_item(Entity.new("_:p6")).all_parents
    assert_equal Set.new([Relation.new("_:keywords")]), set.get_item(Entity.new("_:k3")).all_parents
    assert_equal Set.new([Relation.new("_:publicationYear")]), set.get_item(Literal.new(2000)).all_parents
  end
  
  def test_all_parents_3
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:i1")=>{Relation.new("_:author") => Set.new([Entity.new("_:a1")])},
        Entity.new("_:i2")=>{Relation.new("_:publishedOn") => Set.new([Entity.new("_:journal1")])},
        Entity.new("_:i3")=>{Relation.new("_:publicationYear") => Set.new([Literal.new(2000)])},
        Entity.new("_:i4")=>{Relation.new("_:keywords") => Set.new([Entity.new("_:k3")])},
        Entity.new("_:i5")=>{Relation.new("_:cite", true) => Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])}
      }      
    
    end
    
    assert_equal Set.new([Entity.new("_:i5"), Relation.new("_:cite", true)]), set.get_item(Entity.new("_:p6")).all_parents
    assert_equal Set.new([Entity.new("_:i4"),Relation.new("_:keywords")]), set.get_item(Entity.new("_:k3")).all_parents
    assert_equal Set.new([Entity.new("_:i3"),Relation.new("_:publicationYear")]), set.get_item(Literal.new(2000)).all_parents
  end   
  
  def test_parents_hash
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:i1")=>{Relation.new("_:author") => Set.new([Entity.new("_:a1")])},
        Entity.new("_:i2")=>{Relation.new("_:publishedOn") => Set.new([Entity.new("_:journal1")])},
        Entity.new("_:i3")=>{Relation.new("_:publicationYear") => Set.new([Literal.new(2000)])},
        Entity.new("_:i4")=>{Relation.new("_:keywords") => Set.new([Entity.new("_:k3")])},
        Entity.new("_:i5")=>{Relation.new("_:cite", true) => Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])}
      }      
    
    end
    h1 = {Entity.new("_:i5")=> {Relation.new("_:cite", true)=>{}}}
    h2 = {Entity.new("_:i4")=>{Relation.new("_:keywords")=>{}}}
    h3 = {Entity.new("_:i3") => {Relation.new("_:publicationYear")=>{}}}
    assert_equal h1, set.get_item(Entity.new("_:p6")).parents_hash
    assert_equal h2, set.get_item(Entity.new("_:k3")).parents_hash
    assert_equal h3, set.get_item(Literal.new(2000)).parents_hash
  end
  # def test_find_path
  #
  #   correlate_test = Xset.new do |s|
  #     s << Entity.new("_:o1")
  #   end
  #
  #   correlate_target_test = Xset.new do |s|
  #     s << Entity.new("_:o2")
  #   end
  #
  #   correlate_target_test.server = @correlate_server
  #
  #   correlate_test.server = @correlate_server
  #
  #   actual_results = correlate_test.find_path(correlate_target_test)
  #
  #   expected_rs = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:o1") => {
  #         Entity.new("_:p3") => Entity.new("_:o2"),
  #         Entity.new("_:p1") => {Entity.new("_:p2") => Entity.new("_:o2")}
  #       }
  #     }
  #   end
  #
  #   assert_equal expected_rs.extension, actual_results.extension
  # end
 
end