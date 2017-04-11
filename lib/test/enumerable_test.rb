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
  
  def test_domain
    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>{}}}
      }
      s.server = @papers_server
      s.id = "s2"
    end
    assert_equal [Entity.new("_:paper1")], set2.domain(Entity.new("_:journal1"))
  end

  def test_domain_two_levels

    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>Xsubset.new("key"){|ss| ss.extension = {Entity.new("e")=>{}}}}},
        Entity.new("_:paper2") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>Xsubset.new("key"){|ss| ss.extension = {Entity.new("e")=>{}}}}}
      }
      s.server = @papers_server
      s.id = "s2"
    end
    assert_equal [Entity.new("_:paper1"), Entity.new("_:paper2")], set2.domain(Entity.new("e"))
  end

  def test_trace_subsets
    
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>{}}},
        Entity.new("_:paper2") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal2")=>{}}}
      }
      s.id = "set1"
    end

    set2 = Xset.new do |s|
      s.extension = {
         Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>{}}}=>Xsubset.new("key"){|ss| ss.extension = {Entity.new("e")=>{}}},

      }
      s.server = @papers_server
      s.id = "set2"
      s.resulted_from = set1
    end
    assert_equal [["set1", Entity.new("_:paper1")], ["set2", Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>{}}}]], set2.trace_domains(Entity.new("e"))
  end
  
  def test_trace
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {}
      }
      s.server = @papers_server
      s.id = "s1"
    end
    
    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>{}}}
      }
      s.server = @papers_server
      s.id = "s2"
    end
    
    set3 = Xset.new do |s|
      s.extension = {
        Entity.new("_:journal1") => Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2000) => {}}}
      }
      s.server = @papers_server
      s.id = "s3"
    end
    
    set2.resulted_from = set1
    set3.resulted_from = set2

    expected_rs = [["s1", Entity.new("_:paper1")], ["s2", Entity.new("_:paper1")], ["s3", Entity.new("_:journal1")]]
    assert_equal expected_rs, set3.trace_domains(Xpair::Literal.new(2000))
    
  end
  
  def test_each_image_empty
    set1 = Xset.new do |s|
      s.extension = {}
      s.server = @papers_server
    end
    assert_equal [], set1.each_image
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
        Entity.new("_:paper1") => {Entity.new("_:journal1")=>{}}
      }
      s.server = @papers_server
    end
    expected_rs = Set.new([Entity.new("_:journal1")])
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
        Entity.new("_:paper1") => {Entity.new("_:journal1")=>{}}
      }
      s.server = @papers_server
    end
    set3 = Xset.new do |s|
      s.extension = {
        Entity.new("_:journal1") => {Xpair::Literal.new(2000) => {}}
      }
      s.server = @papers_server
    end

    expected_rs = Set.new([Xpair::Literal.new(2000)])
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
        Entity.new("_:paper1") => 
          Xsubset.new("key"){|ss|
            ss.extension = {
              Entity.new("_:journal1")=>{},
              Entity.new("_:journal2")=>{}
            }
          },
        Entity.new("_:paper2") => 
          Xsubset.new("key"){|ss|
            ss.extension = {
              Entity.new("_:journal2")=>{},
              Entity.new("_:journal3")=>{}
            }
          }
      }
      
      s.server = @papers_server
    end
    
    set3 = Xset.new do |s|
      s.extension = {
        Xsubset.new("key"){|ss|
          ss.extension = {
            Entity.new("_:journal1")=>{},
            Entity.new("_:journal2")=>{}
          }
        } => {Xpair::Literal.new(2000) => {}},
        Xsubset.new("key"){|ss|
          ss.extension = {
            Entity.new("_:journal2")=>{},
            Entity.new("_:journal3")=>{}
          }
        } => {Xpair::Literal.new(2001)=>{}}
        
      }
      s.server = @papers_server
    end
    set3.resulted_from= set2
    set2.resulted_from= set1
    expected_rs = Set.new([Xpair::Literal.new(2000)])

    assert_equal expected_rs, set1.trace_image(Entity.new("_:paper1"), [set2, set3])
  end
  
  def test_trace_image_aggregator2
    set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => {},
        Entity.new("_:paper2") => {}
      }
      s.server = @papers_server
    end
    set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1") => 
          Xsubset.new("key"){|ss|
            ss.extension = {
              Entity.new("_:journal1")=>{},
              Entity.new("_:journal2")=>{}
            }
          },
        Entity.new("_:paper2") => 
          Xsubset.new("key"){|ss|
            ss.extension = {
              Entity.new("_:journal2")=>{},
              Entity.new("_:journal3")=>{}
            }
          }
      }
      s.server = @papers_server
    end
    set3 = Xset.new do |s|
      s.extension = {
        Xsubset.new("key"){|ss|
          ss.extension = {
            Entity.new("_:journal1")=>{},
            Entity.new("_:journal2")=>{}
          }
        } => {Xpair::Literal.new(2000)=>{}},
        Xsubset.new("key"){|ss|
          ss.extension = {
            Entity.new("_:journal2")=>{},
            Entity.new("_:journal3")=>{}
          }
        } => Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2001)=>{},Xpair::Literal.new(2002)=>{} }}
        
      }
      s.server = @papers_server
    end
    expected_rs = Set.new([Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2001)=>{},Xpair::Literal.new(2002)=>{} }}])

    assert_equal expected_rs, set1.trace_image(Entity.new("_:paper2"), [set2, set3])
  end
  
  def test_paginate
    s = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
      s << Entity.new("_:p4")
      s << Entity.new("_:p5")
      s << Entity.new("_:p6")
      s << Entity.new("_:p7")
      s << Entity.new("_:p8")
      s << Entity.new("_:p9")
      s << Entity.new("_:p10")
    end
    s.server = @papers_server
    s.paginate(3)
    assert_equal 4, s.count_pages
    
    assert_equal Set.new([Entity.new("_:paper1"), Entity.new("_:p2"), Entity.new("_:p3")]), Set.new(s.each_image(page: 1))
    assert_equal Set.new([Entity.new("_:p4"), Entity.new("_:p5"), Entity.new("_:p6")]), Set.new(s.each_image(page: 2))
    assert_equal Set.new([Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:p9")]), Set.new(s.each_image(page: 3))
    assert_equal Set.new([Entity.new("_:p10")]), Set.new(s.each_image(page: 4))
    
  end
  
  
  

end