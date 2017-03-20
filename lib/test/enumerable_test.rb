require './test/xpair_unit_test'

class MergeTest < XpairUnitTest

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
  
  def test_update_level
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {Entity.new("_:p3")=>{Entity.new("_:p4")=>{}}}
      }
      s.server = @papers_server
    end
    set1.entities_of_level(1).first.delete(Entity.new("_:paper1"))
    expected_rs = {
      
    }
    assert_equal expected_rs, set1.extension
    
  end
  
  def test_trace_image_single
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {}
      }
      s.server = @papers_server
    end
    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:journal1") => {}
      }
      s.relation_index = {
        Entity.new("_:paper1") => {Entity.new("_:journal1")=>{}}
      }
      s.server = @papers_server
    end
    expected_rs = {Entity.new("_:journal1")=>{}}
    assert_equal expected_rs, set1.trace_image(Entity.new("_:paper1"), [set2])
  end
  
  def test_trace_image_two_steps
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {}
      }
      s.server = @papers_server
    end
    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:journal1") => {}
      }
      s.relation_index = {
        Entity.new("_:paper1") => {Entity.new("_:journal1")=>{}}
      }
      s.server = @papers_server
    end
    set3 = Xset.new do |s|
      s.extension = {
        Xpair::Literal.new(2000) => {}
      }
      s.relation_index = {
        Entity.new("_:journal1") => {Xpair::Literal.new(2000) => {}}
      }
      s.server = @papers_server
    end

    expected_rs = {Entity.new("_:journal1")=>{Xpair::Literal.new(2000) => {}}}
    assert_equal expected_rs, set1.trace_image(Entity.new("_:paper1"), [set2, set3])
  end
  
  def test_trace_image_aggregator
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {},
        Entity.new("_:paper2") => {}
      }
      s.server = @papers_server
    end
    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:journal1") => {},
        Entity.new("_:journal2") => {},
        Entity.new("_:journal3") => {}
      }
      s.relation_index = {
        Entity.new("_:paper1") => {
          Xsubset.new(set2, 1){|ss|
            ss.extension = {
              Entity.new("_:journal1")=>{},
              Entity.new("_:journal2")=>{}
            }
          } => {}
        },
        Entity.new("_:paper2") => {
          Xsubset.new(set2, 1){|ss|
            ss.extension = {
              Entity.new("_:journal2")=>{},
              Entity.new("_:journal3")=>{}
            }
          } => {}
        }
        
      }
      s.server = @papers_server
    end
    set3 = Xset.new do |s|
      s.extension = {
        Xpair::Literal.new(2000) => {}
      }
      s.relation_index = {
        Xsubset.new(set2, 1){|ss|
          ss.extension = {
            Entity.new("_:journal1")=>{},
            Entity.new("_:journal2")=>{}
          }
        } => {Xpair::Literal.new(2000) => {}},
        Xsubset.new(set2, 1){|ss|
          ss.extension = {
            Entity.new("_:journal2")=>{},
            Entity.new("_:journal3")=>{}
          }
        } => {Xpair::Literal.new(2001) => {}}
        
      }
      s.server = @papers_server
    end
    expected_rs = {
      Xsubset.new(set2, 1){|ss|
        ss.extension = {
          Entity.new("_:journal1")=>{},
          Entity.new("_:journal2")=>{}
        }
      } => {Xpair::Literal.new(2000) => {}}
    }
    assert_equal expected_rs, set1.trace_image(Entity.new("_:paper1"), [set2, set3])
  end
  
  def test_trace_image_aggregator
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {},
        Entity.new("_:paper2") => {}
      }
      s.server = @papers_server
    end
    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:journal1") => {},
        Entity.new("_:journal2") => {},
        Entity.new("_:journal3") => {}
      }
      s.relation_index = {
        Entity.new("_:paper1") => {
          Xsubset.new(set2, 1){|ss|
            ss.extension = {
              Entity.new("_:journal1")=>{},
              Entity.new("_:journal2")=>{}
            }
          } => {}
        },
        Entity.new("_:paper2") => {
          Xsubset.new(set2, 1){|ss|
            ss.extension = {
              Entity.new("_:journal2")=>{},
              Entity.new("_:journal3")=>{}
            }
          } => {}
        }
        
      }
      s.server = @papers_server
    end
    set3 = Xset.new do |s|
      s.extension = {
        Xpair::Literal.new(2000) => {},
        Xpair::Literal.new(2001) => {},
        Xpair::Literal.new(2002) => {}
      }
      s.relation_index = {
        Entity.new("_:journal1")=>{Xpair::Literal.new(2001) => {}},
        Entity.new("_:journal2") => {Xpair::Literal.new(2000) => {}},
        Entity.new("_:journal3")=>{Xpair::Literal.new(2002) => {}}
      }
      s.server = @papers_server
    end
    expected_rs = {
      Entity.new("_:journal1")=>{Xpair::Literal.new(2001) => {}},
      Entity.new("_:journal2") => {Xpair::Literal.new(2000) => {}}
    }
    assert_equal expected_rs, set1.trace_image(Entity.new("_:paper1"), [set2, set3])
  end
end