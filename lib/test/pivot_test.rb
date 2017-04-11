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
  
  def test_empty
    set = Xset.new do |s|
    end
    set.server = @papers_server
    


    
    assert_true set.pivot_forward([Relation.new("_:cite")]).empty?
    assert_true set.pivot_backward([Relation.new("_:cite")]).empty?
    assert_true set.pivot().empty?    
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

    expected_extension = {
      Entity.new("_:p1") => Xsubset.new("key"){|s| s.extension = {Relation.new("_:r1")=>{}}},
      Entity.new("_:p2") => Xsubset.new("key"){|s| s.extension = {Relation.new("_:r1")=>{}}},
      Entity.new("_:p3") => Xsubset.new("key"){|s| s.extension = {Relation.new("_:r1")=>{}}},
      Entity.new("_:p4") => Xsubset.new("key"){|s| s.extension = {Relation.new("_:r2")=>{}}},
      Entity.new("_:p5") => Xsubset.new("key"){|s| s.extension = {Relation.new("_:r2")=>{}}}
      
    }
    rs = test_set.relations
    assert_equal expected_extension, rs.extension
    # assert_equal expected_index, rs.relation_index
  end
  
  
  def test_pivot_forward
    
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server    
    
    rs = set.pivot_forward(["_:r1"])
    expected_extension = {

      Entity.new("_:p1")=>
       Xsubset.new("key"){|s| s.extension[Relation.new("_:r1")] = Xsubset.new("key") do |s|
          s.extension = {
            Entity.new("_:o1") =>{}, 
            Entity.new("_:o2")=>{}
          }
        end
      },
      Entity.new("_:p2")=> Xsubset.new("key"){|s| s.extension[Relation.new("_:r1")] = Xsubset.new("key"){|s| s.extension = {Entity.new("_:o2") => {}}}},
      Entity.new("_:p3")=> Xsubset.new("key"){|s| s.extension[Relation.new("_:r1")] = Xsubset.new("key"){|s| s.extension = {Entity.new("_:o3")=>{}}}},    
    }
        
    assert_equal expected_extension, rs.extension
    # assert_equal expected_index, rs.relation_index
  end
  
  # def test_pivot_forward_keep_structure
  #   set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #   end
  #
  #   set.server = @server
  #
  #   expected_extension = {
  #     Entity.new("_:o1") => {},
  #     Entity.new("_:o2") => {},
  #     Entity.new("_:o3") => {}
  #   }
  #   rs = set.pivot_forward(["_:r1"], keep_structure: true)
  #   expected_index = {
  #     Entity.new("_:p1")=>{
  #       Entity.new("_:o1") =>{},
  #       Entity.new("_:o2")=>{}
  #     },
  #     Entity.new("_:p2")=> {Entity.new("_:o2") => {}},
  #     Entity.new("_:p3")=>{Entity.new("_:o3")=>{}},
  #   }
  #
  #   assert_equal expected_index, rs.extension
  #   assert_equal expected_index, rs.relation_index
  # end
  
  def test_pivot_property_path
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:paper1")=>Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1") => {}, Entity.new("_:a2") => {}}},
      Entity.new("_:p6")    =>Xsubset.new("key"){|s| s.extension = {Entity.new("_:a2") => {}, Entity.new("_:a1") => {}}}
    }
    rs = set.pivot_forward([["_:cite", "_:author"]])
    assert_equal expected_extension, rs.extension
    # assert_equal expected_index, rs.relation_index
  end
  
  # def test_pivot_property_path_keep_structure
  #   set = Xset.new do |s|
  #     s << Entity.new("_:paper1")
  #     s << Entity.new("_:p6")
  #   end
  #   set.server = @papers_server
  #   expected_index = {
  #     Entity.new("_:paper1")=>{Entity.new("_:a1") => {}, Entity.new("_:a2") => {}},
  #     Entity.new("_:p6")    =>{Entity.new("_:a1") => {}, Entity.new("_:a2") => {}},
  #
  #   }
  #   expected_extension = {
  #     Entity.new("_:a1") => {},
  #     Entity.new("_:a2") => {}
  #   }
  #   rs = set.pivot_forward([["_:cite", "_:author"]], keep_structure: true)
  #   assert_equal expected_index, rs.extension
  #   assert_equal expected_index, rs.relation_index
  # end
  
  
  def test_pivot_multiple_relations
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    subset1 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:a1")=>{},
        Entity.new("_:a2")=>{}
      }
    end
    subset2 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p4")=>{}
      }
    end
    subset3 = Xsubset.new("key") do |s|
      s.extension = {
        Relation.new("_:author")=>subset1,
        Relation.new("_:cite")=> subset2,
      }
    end
    
    subset4 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:a2")=>{}
      }
    end
    
    subset5 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p5")=>{}
      }
    end
    
    subset6 = Xsubset.new("key") do |s|
      s.extension = {
        Relation.new("_:author")=>subset4,
        Relation.new("_:cite")=> subset5,        
      }
    end

    expected_extension = {
      Entity.new("_:paper1")=> subset3,
      Entity.new("_:p6")=> subset6
    }
    rs = set.pivot_forward(["_:cite", "_:author"])
    assert_equal expected_extension, rs.extension

    # assert_equal expected_index, rs.relation_index
  end
  
  def test_pivot_keep_structure
    set = Xset.new do |s|
      s << Entity.new("_:p2")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:journal1") => Xsubset.new do |s|
        s.extension = {Xpair::Literal.new("2005") => {}}
      end
    }
    rs = set.pivot_forward([Relation.new("_:publishedOn")]).pivot_forward([Relation.new("_:releaseYear")])
    assert_equal expected_extension, rs.extension
  end
  
  def test_pivot
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    subset1 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:a1")=>{},
        Entity.new("_:a2")=>{}
      }
    end
    subset2 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p4")=>{}
      }
    end
    
    subset4 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:a2")=>{}
      }
    end
    subset8 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:journal1")=>{}
      }
    end
    
    subset5 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p5")=>{}
      }
    end
    subset7 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:k1")=>{},
        Entity.new("_:k2")=>{},
        Entity.new("_:k3")=>{}
      }
    end
    
    subset6 = Xsubset.new("key") do |s|
      s.extension = {
        Relation.new("_:author")=>subset4,
        Relation.new("_:cite")=> subset5,        
      }
    end
    subset3 = Xsubset.new("key") do |s|
      s.extension = {
        Relation.new("_:author")=>subset1,
        Relation.new("_:cite")=> subset2,
        Relation.new("_:keywords")=> subset7,
        Relation.new("_:submittedTo")=> subset8,
      }
    end

    expected_extension = {
      Entity.new("_:paper1")=> subset3,
      Entity.new("_:p6")=> subset6
    }
    rs = set.pivot()
    assert_equal expected_extension, rs.extension
    
  end
  
  
  def test_pivot_backward
    set = Xset.new do |s|
      s << Entity.new("_:o1")
      s << Entity.new("_:o2")
      s.resulted_from =  Xset.new{|os| os.server = @server}
    end

    set.server = @server

    expected_extension = {
       Entity.new("_:o2")=>Xsubset.new("key") do |s|
         s.extension[Relation.new("_:r1", true)]=Xsubset.new("key") do |s| 
           s.extension = {
             Entity.new("_:p1")=>{},
             Entity.new("_:p2")=>{}
           }
         end
       end,
       Entity.new("_:o1")=>Xsubset.new("key") do |s|
          s.extension[Relation.new("_:r1", true)]=Xsubset.new("key") do |s| 
            s.extension = {
               Entity.new("_:p1")=>{}
             }
           end
       end
    }
    rs = set.pivot_backward(["_:r1"])
    # assert_equal rs[Entity.new("_:o2")].first.keys.first.text, "_:r1 of"
    assert_equal expected_extension, rs.extension

  end
end