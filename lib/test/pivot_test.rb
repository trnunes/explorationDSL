require './test/xpair_unit_test'

class PivotTest < XpairUnitTest

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
  
  def test_relations
    test_set = Xset.new do |s|
      s.server = @server
      s.resulted_from = Xset.new
      s.extension = {
        Entity.new("_:p1") => {},
        Entity.new("_:p2") => {},
        Entity.new("_:p3") => {},
        Entity.new("_:p4") => {},
        Entity.new("_:p5") => {}        
      }
    end
    test_set.each
    expected_extension = {
      Relation.new("_:r1") => { },
      Relation.new("_:r2") => {}
    }
    expected_index = {
      Entity.new("_:p1") => {Relation.new("_:r1")=>{}},
      Entity.new("_:p2") => {Relation.new("_:r1")=>{}},
      Entity.new("_:p3") => {Relation.new("_:r1")=>{}},
      Entity.new("_:p4") => {Relation.new("_:r2")=>{}},
      Entity.new("_:p5") => {Relation.new("_:r2")=>{}}
      
    }
    rs = test_set.relations
    assert_equal expected_extension, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  def test_relations_keep_structure
    test_set = Xset.new do |s|
      s.server = @server
      s.resulted_from = Xset.new
      s.extension = {
        Entity.new("_:p1") => {},
        Entity.new("_:p2") => {},
        Entity.new("_:p3") => {},
        Entity.new("_:p4") => {},
        Entity.new("_:p5") => {}        
      }
    end
    test_set.each
    expected_extension = {
      Relation.new("_:r1") => { },
      Relation.new("_:r2") => {}
    }
    expected_index = {
      Entity.new("_:p1") => {Relation.new("_:r1")=>{}},
      Entity.new("_:p2") => {Relation.new("_:r1")=>{}},
      Entity.new("_:p3") => {Relation.new("_:r1")=>{}},
      Entity.new("_:p4") => {Relation.new("_:r2")=>{}},
      Entity.new("_:p5") => {Relation.new("_:r2")=>{}}
      
    }
    rs = test_set.relations(keep_structure: true)
    assert_equal expected_index, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  
  def test_pivot_forward
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server    
    
    expected_extension = { 
      Entity.new("_:o1") => {},
      Entity.new("_:o2") => {},
      Entity.new("_:o3") => {}
    }
    rs = set.pivot_forward(["_:r1"])
    expected_index = {
      Entity.new("_:p1")=>{
        Entity.new("_:o1") =>{}, 
        Entity.new("_:o2")=>{}
      },
      Entity.new("_:p2")=> {Entity.new("_:o2") => {}},
      Entity.new("_:p3")=>{Entity.new("_:o3")=>{}},    
    }
        
    assert_equal expected_extension, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  def test_pivot_forward_keep_structure
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server    
    
    expected_extension = { 
      Entity.new("_:o1") => {},
      Entity.new("_:o2") => {},
      Entity.new("_:o3") => {}
    }
    rs = set.pivot_forward(["_:r1"], keep_structure: true)
    expected_index = {
      Entity.new("_:p1")=>{
        Entity.new("_:o1") =>{}, 
        Entity.new("_:o2")=>{}
      },
      Entity.new("_:p2")=> {Entity.new("_:o2") => {}},
      Entity.new("_:p3")=>{Entity.new("_:o3")=>{}},    
    }
        
    assert_equal expected_index, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  def test_pivot_property_path
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_index = {
      Entity.new("_:paper1")=>{Entity.new("_:a1") => {}, Entity.new("_:a2") => {}},
      Entity.new("_:p6")    =>{Entity.new("_:a1") => {}, Entity.new("_:a2") => {}},
      
    }
    expected_extension = {
      Entity.new("_:a1") => {},
      Entity.new("_:a2") => {}
    }
    rs = set.pivot_forward([["_:cite", "_:author"]])
    assert_equal expected_extension, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  def test_pivot_property_path_keep_structure
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_index = {
      Entity.new("_:paper1")=>{Entity.new("_:a1") => {}, Entity.new("_:a2") => {}},
      Entity.new("_:p6")    =>{Entity.new("_:a1") => {}, Entity.new("_:a2") => {}},
      
    }
    expected_extension = {
      Entity.new("_:a1") => {},
      Entity.new("_:a2") => {}
    }
    rs = set.pivot_forward([["_:cite", "_:author"]], keep_structure: true)
    assert_equal expected_index, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  def test_pivot_property_path_2
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:p1") => {},
        Entity.new("_:p2") => {},
        Entity.new("_:p3") => {},
        Entity.new("_:p4") => {},
        Entity.new("_:p5") => {},
        Entity.new("_:p6") => {},
        Entity.new("_:paper1") => {}                        
      }
    end
    set.server = @papers_server
    expected_index = {
      Entity.new("_:2010") => {
        Entity.new("_:paper1") => {
          Relation.new("_:cite") => {
            Entity.new("_:p2")=>Relation.new("_:author")
          }
        },
        Entity.new("_:p6") => {
          Relation.new("_:cite") => {
            Entity.new("_:p2")=>Relation.new("_:author"),
            Entity.new("_:p5")=>Relation.new("_:author")
          }
        }
      },
      Entity.new("_:a2") => {
        Entity.new("_:paper1") => {
          Relation.new("_:cite") => {
            Entity.new("_:p3") => Relation.new("_:author")
          }
        },
        Entity.new("_:p6") => {
          Relation.new("_:cite") => {
            Entity.new("_:p3") => Relation.new("_:author"),
            Entity.new("_:p5") => Relation.new("_:author") 
          }
        }
      }
    }
    expected_extension = {
      Entity.new("_:2010") => {},
      Entity.new("_:a2") => {}
    }
    # assert_equal expected_extension, set.pivot_forward([["_:publishedOn", "_:releaseYear"]]).extension
  end
  
  
  
  def test_pivot_with_backward_relations_keep_structure
    set = Xset.new do |s|
      s << Entity.new("_:p2")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:p2") => {
        Relation.new("_:author") => {Entity.new("_:a1")=>{}},
        Relation.new("_:publishedOn") => {Entity.new("_:journal1")=>{}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2000)=>{}},
        Relation.new("_:keywords") => {Entity.new("_:k3")=>{}},
        Relation.new("_:cite", true) => {Entity.new("_:paper1")=>{}, Entity.new("_:p6")=>{}}
      }
    }
    
    expected_index = {
      Entity.new("_:p2") => {
        Relation.new("_:author") => {Entity.new("_:a1")=>{}},
        Relation.new("_:publishedOn") => {Entity.new("_:journal1")=>{}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2000)=>{}},
        Relation.new("_:keywords") => {Entity.new("_:k3")=>{}},
        Relation.new("_:cite", true) => {Entity.new("_:paper1")=>{}, Entity.new("_:p6")=>{}}
      }
    }

    rs = set.pivot(keep_structure: true)

    assert_equal expected_extension, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  def test_pivot_with_backward_relations
    set = Xset.new do |s|
      s << Entity.new("_:p2")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:p2") => {
        Relation.new("_:author") => {Entity.new("_:a1")=>{}},
        Relation.new("_:publishedOn") => {Entity.new("_:journal1")=>{}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2000)=>{}},
        Relation.new("_:keywords") => {Entity.new("_:k3")=>{}},
        Relation.new("_:cite", true) => {Entity.new("_:paper1")=>{}, Entity.new("_:p6")=>{}}
      }
    }
    
    expected_index = {
      Entity.new("_:p2") => {
        Relation.new("_:author") => {Entity.new("_:a1")=>{}},
        Relation.new("_:publishedOn") => {Entity.new("_:journal1")=>{}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2000)=>{}},
        Relation.new("_:keywords") => {Entity.new("_:k3")=>{}},
        Relation.new("_:cite", true) => {Entity.new("_:paper1")=>{}, Entity.new("_:p6")=>{}}
      }
    }

    rs = set.pivot

    assert_equal expected_extension, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  
  def test_pivot_multiple_relations
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:a1") => {},
            
      Entity.new("_:a2") => {},
      
      Entity.new("_:p2") => {},
      
      Entity.new("_:p3") => {},
      
      Entity.new("_:p4") => {},
      
      Entity.new("_:p5") => {}
    }
        
    expected_index = {
      Entity.new("_:paper1")=>{
        Relation.new("_:author")=>{
          Entity.new("_:a1")=>{},
          Entity.new("_:a2")=>{}
        },
        Relation.new("_:cite")=>{
          Entity.new("_:p2")=>{},
          Entity.new("_:p3")=>{},
          Entity.new("_:p4")=>{}
        }
      },
      Entity.new("_:p6")    =>{
        Relation.new("_:author")=>{
          Entity.new("_:a2")=>{}
        },
        Relation.new("_:cite")=>{
          Entity.new("_:p2")=>{},
          Entity.new("_:p3")=>{},
          Entity.new("_:p5")=>{}          
        }
      },
    }
    rs = set.pivot_forward(["_:cite", "_:author"])
    assert_equal expected_extension, rs.extension

    assert_equal expected_index, rs.relation_index
  end
  
  
  def test_pivot_backward
    set = Xset.new do |s| 
      s << Entity.new("_:o1")
      s << Entity.new("_:o2")
      s.resulted_from =  Xset.new{|os| os.server = @server}
    end
    
    set.server = @server
    
    expected_extension = {
      Entity.new("_:p1") => {},
      Entity.new("_:p2") => {}
    }
    expected_index = {
       Entity.new("_:o2")=>{
         Entity.new("_:p1")=>{},
         Entity.new("_:p2")=>{}
       },
       Entity.new("_:o1")=>{
         Entity.new("_:p1")=>{}
       }
    }
    rs = set.pivot_backward(["_:r1"])
    assert_equal expected_extension, rs.extension
    assert_equal expected_index, rs.relation_index
  end
  
  def test_pivot_level2
    set = Xset.new do |s|
      s.extension = {
        Relation.new("_:cite") => {Entity.new("_:p3")=> {},Entity.new("_:p4")=> {}}
      }
    end
    
    set.server = @papers_server
    h1 = {Relation.new("_:cite")=>{Entity.new("_:journal1") => {}, Entity.new("_:journal2") => {}}}
    assert_equal h1, set.pivot_forward([Relation.new("_:publishedOn")],level: 2).extension
    
    h2 = {
      Relation.new("_:cite")=> {Entity.new("_:journal1") => {}, Entity.new("_:journal2")=> {},Xpair::Literal.new(1998) => {},Xpair::Literal.new(2010) => {}}
      
    }
    
    expected_index = {
      Entity.new("_:p3")=> {
        Relation.new("_:publishedOn")=> {Entity.new("_:journal2")=> {}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(1998) => {}}
      },
      Entity.new("_:p4")=> {
        Relation.new("_:publishedOn")=> {Entity.new("_:journal1") => {}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2010) => {}}
      }      
    }
    rs = set.pivot_forward([Relation.new("_:publishedOn"), Relation.new("_:publicationYear")], level: 2)
    assert_equal h2, rs.extension
    assert_equal expected_index, rs.relation_index
    
  end
  
  def test_pivot_level3_two_parents
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1")=>{Relation.new("_:cite") => {Entity.new("_:p3")=> {},Entity.new("_:p4")=>{}}}
        
      }      
    
    end
    set.server = @papers_server
    h1 = {Entity.new("_:paper1")=>{Relation.new("_:cite")=>{Entity.new("_:journal1")=>{},Entity.new("_:journal2")=>{}}}}
    assert_equal h1, set.pivot_forward([Relation.new("_:publishedOn")],level: 3).extension
    
    h2 = {
      Entity.new("_:paper1")=>{Relation.new("_:cite")=> {Entity.new("_:journal1") => {},Entity.new("_:journal2")=> {},Xpair::Literal.new(1998)=> {},Xpair::Literal.new(2010) => {}}}
      
    }
    expected_index = {
      Entity.new("_:p3")=> {
        Relation.new("_:publishedOn")=> {Entity.new("_:journal2")=> {}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(1998) => {}}
      },
      Entity.new("_:p4")=> {
        Relation.new("_:publishedOn")=> {Entity.new("_:journal1") => {}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2010) => {}}
      }      
    }
    rs = set.pivot_forward([Relation.new("_:publishedOn"), Relation.new("_:publicationYear")], level: 3)
    assert_equal h2, rs.extension
    assert_equal expected_index, rs.relation_index
    
  end
  
  def test_pivot_level3_siblings
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1")=>{Relation.new("_:cite") => {Entity.new("_:p3") => {},Entity.new("_:p4") => {}}},
        Entity.new("_:p5")=>{Relation.new("_:cite") => {Entity.new("_:p2")=>{}}}
      }      
    
    end
    set.server = @papers_server
    h1 = {
      Entity.new("_:paper1")=>{Relation.new("_:cite")=>{Entity.new("_:journal1") => {},Entity.new("_:journal2") => {}}},
      Entity.new("_:p5")=>{Relation.new("_:cite")=>{Entity.new("_:journal1") => {}}}
    }

    assert_equal h1, set.pivot_forward([Relation.new("_:publishedOn")], level: 3).extension

    h2 = {
      Entity.new("_:paper1")=>{Relation.new("_:cite")=> {Entity.new("_:journal1") => {},Entity.new("_:journal2") => {},Xpair::Literal.new(1998)=> {},Xpair::Literal.new(2010)=> {}}},
      Entity.new("_:p5")=>{Relation.new("_:cite")=> {Entity.new("_:journal1")=>{}, Xpair::Literal.new(2000)=>{}}}

    }
    expected_index = {
      Entity.new("_:p3")=> {
        Relation.new("_:publishedOn")=> {Entity.new("_:journal2")=> {}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(1998) => {}}
      },
      Entity.new("_:p4")=> {
        Relation.new("_:publishedOn")=> {Entity.new("_:journal1") => {}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2010) => {}}
      },
      Entity.new("_:p2")=> {
        Relation.new("_:publishedOn")=> {Entity.new("_:journal1") => {}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2000) => {}}
      }
    }
    rs = set.pivot_forward([Relation.new("_:publishedOn"), Relation.new("_:publicationYear")], level: 3)
    assert_equal h2, rs.extension
    assert_equal expected_index, rs.relation_index
    
  end

  def test_pivot_level2_property_path
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1")=>{Relation.new("_:cite") => {Entity.new("_:p3")=>{},Entity.new("_:p4")=>{}}},
        Entity.new("_:p5")=>{Relation.new("_:cite") => {Entity.new("_:p2")=>{}}}
      }      
    
    end
    set.server = @papers_server
    h1 = {
      Entity.new("_:paper1")=>{Relation.new("_:cite")=>{Xpair::Literal.new(2005)=>{}, Xpair::Literal.new(2010)=>{}}},
      Entity.new("_:p5")=>{Relation.new("_:cite")=>{Xpair::Literal.new(2005)=>{}}}
    }
    
    expected_index = {
      Entity.new("_:p3")=> {
        Xpair::Literal.new(2010)=>{}
      },
      Entity.new("_:p4")=> {
        Xpair::Literal.new(2005)=>{}
      },
      Entity.new("_:p2")=> {
        Xpair::Literal.new(2005)=>{}
      }
    }
    rs = set.pivot_forward([[Relation.new("_:publishedOn"), Relation.new("_:releaseYear")]],level: 3)
    assert_equal h1, rs.extension

    assert_equal expected_index, rs.relation_index

  end
  
  
end