require './test/xpair_unit_test'

class GroupTest < XpairUnitTest

  def setup
    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:year"), 2005]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:year"), 2005]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r1"), RDF::URI("_:o3")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:year"), 2010]
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
  def test_group_by
    test_set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    test_set.server = @server
    
    rs = test_set.group{|gf| gf.by_relation(relations: [Relation.new("_:r1")])}
    
    expected_set = Xset.new do |s|
      s.extension = {
        Entity.new("_:o1") => Xsubset.new("key"){|s|
          s.extension = {
            Entity.new("_:p1")=>{}
          }
        },
        Entity.new("_:o2") => Xsubset.new("key"){|s|
          s.extension = {
            Entity.new("_:p1")=>{},
            Entity.new("_:p2")=>{}
          }
        },
        Entity.new("_:o3") => Xsubset.new("key"){|s|
          s.extension = {
            Entity.new("_:p3")=>{}
          }
        },
      }
    end
    assert_equal expected_set.extension, rs.extension

  end
  
  def test_group_by_keep_structure
    test_set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    test_set.server = @server
    
    rs1 = test_set.group{|gf| gf.by_relation(relations: [Relation.new("_:r1")])}

    expected_set = Xset.new do |s|
      s.extension = {
        Entity.new("_:o1") => Xsubset.new("key"){|s|
          s.extension = {
            Entity.new("_:p1")=>{}
          }
        },
        Entity.new("_:o2") => Xsubset.new("key"){|s|
          s.extension = {
            Entity.new("_:p1")=>{},
            Entity.new("_:p2")=>{}
          }
        },
        Entity.new("_:o3") => Xsubset.new("key"){|s|
          s.extension = {
            Entity.new("_:p3")=>{}
          }
        },
      }
    end
    expected_set.server = @server
    
    assert_equal expected_set.extension, rs1.extension
    
    rs = rs1.group{|gf| gf.by_relation(relations: [Relation.new("_:year")])}
    
    key1 = Xsubset.new("key"){|s|
      s.extension = {
        Entity.new("_:p1")=>{}
      }
    }
    key2 = Xsubset.new("key"){|s|
      s.extension = {
        Entity.new("_:p1")=>{},
        Entity.new("_:p2")=>{}
      }
    }
    key3 =  Xsubset.new("key"){|s|
      s.extension = {
        Entity.new("_:p3")=>{}
      }
    }
    group1 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p1")=>{}}}
    group2 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p1")=>{}, Entity.new("_:p2")=>{}}}
    group3 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p3")=>{}}}
    
    group4 = Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2005)=>group1}}
    group5 = Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2005)=>group2}}
    group6 = Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2010)=>group3}}
    expected_extension = {
      Xsubset.new("key"){|s|
        s.extension = {
          Entity.new("_:p1")=>{}
        }
      } => group4,
      Xsubset.new("key"){|s|
        s.extension = {
          Entity.new("_:p1")=>{},
          Entity.new("_:p2")=>{}
        }
      } => group5,
      Xsubset.new("key"){|s|
        s.extension = {
          Entity.new("_:p3")=>{}
        }
      }=> group6
    }
    

    rs.extension.each do |key, values|


      HashHelper.print_hash key.extension


      values.extension.each do |key, values|


        HashHelper.print_hash values.extension
      end
        
      
    end

    rs.extension.keys.each do |key|

      HashHelper.print_hash key.extension
    end

    expected_extension.keys.each do |key|

      HashHelper.print_hash key.extension
    end
    
    assert_equal Set.new(rs.extension.keys), Set.new(expected_extension.keys)
    assert_equal rs.extension[key1], expected_extension[key1]

    assert_equal expected_extension, rs.extension
  end
  
end