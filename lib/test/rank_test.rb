require './test/xpair_unit_test'

class RankTest < XpairUnitTest

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
    #
    # @correlate_graph = RDF::Graph.new do |graph|
    #   graph << [RDF::URI("_:o1"), RDF::URI("_:r1"), RDF::URI("_:p1")]
    #   graph << [RDF::URI("_:o1"), RDF::URI("_:r1"), RDF::URI("_:p3")]
    #   graph << [RDF::URI("_:o2"), RDF::URI("_:r1"), RDF::URI("_:p3")]
    #   graph << [RDF::URI("_:p1"), RDF::URI("_:r1"), RDF::URI("_:p2")]
    #   graph << [RDF::URI("_:o2"), RDF::URI("_:r1"), RDF::URI("_:p2")]
    # end
    #
    # @correlate_server = RDFDataServer.new(@correlate_graph)
    #
    # @keyword_refine_graph = RDF::Graph.new do |graph|
    #   graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), "keyword1"]
    #   graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), "keyword2 keyword 3"]
    #   graph << [RDF::URI("_:p2"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
    #   graph << [RDF::URI("_:p3"),  RDF::URI("_:r1"), RDF::URI("_:o3")]
    #   graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o4")]
    #   graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o5")]
    #   graph << [RDF::URI("_:p5"),  RDF::URI("_:r2"), RDF::URI("_:o6")]
    # end
    #
    # expected_extension = {
    #   Entity.new("_:a1") => Set.new([3]),
    #   Entity.new("_:a2") => Set.new([2])
    # }
    
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
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal3")]
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), 2005]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), 2010]
      graph << [RDF::URI("_:journal3"),  RDF::URI("_:releaseYear"), 2007]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), 2000]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), 1998]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), 2010]
    end

    @papers_server = RDFDataServer.new(papers_graph)
      
  end
  
  def test_alhpa_rank
    test_set = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {},
        Entity.new("_:p2") => {},
        Entity.new("_:a4") => {},
        Entity.new("_:b4") => {},
      }
    end
    expected_extension = {
      Entity.new("_:a4") => {},
      Entity.new("_:b4") => {},
      Entity.new("_:p2") => {},
      Entity.new("_:p4") => {},
    }
    
    assert_equal expected_extension, test_set.rank{|rf| rf.alpha_rank}.extension
    
  end
    
  def test_rank_by_set_relation
    test_set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {},
        Entity.new("_:p2") => {}
      }
    end
    test_set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {
          Entity.new("r")=> {
            Entity.new("_:i1") => {Xpair::Literal.new(20)=>{}}

          }
        },
        Entity.new("_:p2") => {
          Entity.new("r")=> {
            Entity.new("_:i1") => {Xpair::Literal.new(30)=>{}},
          }          
        },
      }
      s.relation_index = {
        Entity.new("_:p4") => {
          Entity.new("r")=> {
            Entity.new("_:i1") => {Xpair::Literal.new(20)=>{}}

          }
        },
        Entity.new("_:p2") => {
          Entity.new("r")=> {
            Entity.new("_:i1") => {Xpair::Literal.new(30)=>{}},
          }          
        }
      }
      s.resulted_from = test_set1
    end
    
    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p4") => {}
    }
    
    assert_equal expected_extension, test_set1.rank{|rf| rf.by_relation([test_set2])}.extension
    
  end
  
  def test_rank_by_schema_relation
    test_set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {},
        Entity.new("_:p3") => {},
        Entity.new("_:p2") => {}
      }
      s.server = @papers_server
    end
    
    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p3") => {},
      Entity.new("_:p4") => {}
    }
    
    assert_equal expected_extension, test_set1.rank{|rf| rf.by_relation([Relation.new("_:publicationYear")])}.extension
    
  end
  
  def test_rank_by_two_steps
    test_set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {},
        Entity.new("_:p4") => {},
        Entity.new("_:p2") => {},
        Entity.new("_:p3") => {}
      }
      s.server = @papers_server
    end
    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p3") => {},
      Entity.new("_:p4") => {},
      Entity.new("_:paper1") => {}
    }
    
    set1 = test_set1.pivot_forward([Relation.new("_:publishedOn")])
    set2 = set1.pivot_forward([Relation.new("_:releaseYear")])
    rs = test_set1.rank{|gf| gf.by_relation([set2, set1])}
    HashHelper.print_hash(rs.extension)
    assert_equal expected_extension, rs.extension
  end
  
    
end