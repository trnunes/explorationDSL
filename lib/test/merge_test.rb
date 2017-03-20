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
  
  def test_merge
    origin_set = Xset.new do |s|      
      s.extension = {
        Entity.new("_:i1")=>{Relation.new("r")=>{Entity.new("_:t1")=>{}}},
        Entity.new("_:i2")=>{Relation.new("r")=>{Entity.new("_:t2")=>{}}},
        Entity.new("_:i3")=>{Relation.new("r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t3")=>{}}},
        Entity.new("_:i4")=>{Relation.new("r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t4")=>{}}}
      }
      
    end    
    
    target_set = Xset.new do |s|
      s.extension = {
        Entity.new("_:t1")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}},
        Entity.new("_:t2")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}},
        Entity.new("_:t3")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}},
        Entity.new("_:t4")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}}
      }
    end
    

    expected_extension = {
      Entity.new("_:i1")=>{Relation.new("r")=>{Entity.new("_:t1")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}}}},
      Entity.new("_:i2")=>{Relation.new("r")=>{Entity.new("_:t2")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}}}},
      Entity.new("_:i3")=>{Relation.new("r")=>{
        Entity.new("_:t1")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}}, 
        Entity.new("_:t3")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}}
        }
      },
      Entity.new("_:i4")=>{Relation.new("r")=>{
        Entity.new("_:t1")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}},
        Entity.new("_:t4")=>{Relation.new("r")=>{Entity.new("_:w1")=>{}}}
        }
      }
    }
    assert_equal expected_extension, origin_set.merge!([target_set]).extension
    assert_equal expected_extension, origin_set.extension
    assert_equal 5, origin_set.count_levels
  end
  
  def test_merge_missing_image
    mid_set = Xset.new do |s|
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{}}}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t3")=>{}}}
      s.extension[Entity.new("_:i4")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t4")=>{}}}
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
      s << Entity.new("_:i3")
    end
    expected_extension = {
      Entity.new("_:i1") => {},
       Entity.new("_:i2") => {
         Entity.new("_:r")=>{Entity.new("_:t2")=>{}}
       },
       Entity.new("_:i3") => {
         Entity.new("_:r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t3")=>{}},
      }
    }
    assert_equal 1, origin_set.count_levels
    assert_equal expected_extension, origin_set.merge!([mid_set]).extension
    assert_equal expected_extension, origin_set.extension
    assert_equal 3, origin_set.count_levels
  end
  
  def test_merge_twice
    target_set = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= {Entity.new("_:r")=>{Entity.new("_:u1")=>{}}}
      s.extension[Entity.new("_:t2")]= {Entity.new("_:r")=>{Entity.new("_:u2")=>{}}}
      s.extension[Entity.new("_:t3")]= {Entity.new("_:r")=>{Entity.new("_:u3")=>{}}}
      s.extension[Entity.new("_:t4")]= {Entity.new("_:r")=>{Entity.new("_:u4")=>{}}}
    end
    
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}}}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{}}}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t3")=>{}}}
      s.extension[Entity.new("_:i4")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t4")=>{}}}
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
      s << Entity.new("_:i3")
      s << Entity.new("_:i4")
    end
    local_path = origin_set.merge!([mid_set_1, target_set])
    expected_extension = {
     Entity.new("_:i1") => {
       Entity.new("_:r")=>{
         Entity.new("_:t1") => {
           Entity.new("_:r")=>{Entity.new("_:u1")=>{}}
         }
       }
     },
     Entity.new("_:i2") => {
       Entity.new("_:r")=>{
         Entity.new("_:t2") => {
           Entity.new("_:r")=>{Entity.new("_:u2")=>{}}
         }
       }
     },
     Entity.new("_:i3") => {
       Entity.new("_:r")=>{
        Entity.new("_:t1") => {
          Entity.new("_:r")=>{Entity.new("_:u1")=>{}}
        },
        Entity.new("_:t3") => {
          Entity.new("_:r")=>{Entity.new("_:u3")=>{}}
        }
       }
      },
      Entity.new("_:i4") => {
        Entity.new("_:r")=>{
          Entity.new("_:t1") => {
            Entity.new("_:r")=>{Entity.new("_:u1")=>{}}
            },          
          Entity.new("_:t4") => {
            Entity.new("_:r")=>{Entity.new("_:u4")=>{}}
          }
        }
      }        
    }

    assert_equal expected_extension, local_path.extension
    assert_equal expected_extension, origin_set.extension

  end
  
  def test_merge_two_steps
    target_set = Xset.new do |s|
      s.extension[Entity.new("_:w1")]= {Entity.new("_:r")=>{Entity.new("_:u1")=>{}}}
      s.extension[Entity.new("_:w2")]= {Entity.new("_:r")=>{Entity.new("_:u2")=>{}}}
      s.extension[Entity.new("_:w3")]= {Entity.new("_:r")=>{Entity.new("_:u3")=>{}}}
      s.extension[Entity.new("_:w4")]= {Entity.new("_:r")=>{Entity.new("_:u4")=>{}}}
      
    end
    
    origin_set = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{Entity.new("_:w1")=>{}}}}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{Entity.new("_:w2")=>{}}}}
    end
        
    local_path = origin_set.merge!([target_set])
    expected_extension = {
      Entity.new("_:i1") => {
         Entity.new("_:r")=>{
           Entity.new("_:t1")=>{
             Entity.new("_:w1") => {
               Entity.new("_:r")=>{Entity.new("_:u1")=>{}}
             }
           }
         }
       },
      Entity.new("_:i2") => {
         Entity.new("_:r")=>{
           Entity.new("_:t2")=>{
             Entity.new("_:w2") => {
               Entity.new("_:r")=>{Entity.new("_:u2")=>{}}
             }
           }
         }
      },
    }

    assert_equal expected_extension, local_path.extension
    assert_equal expected_extension, origin_set.extension
    
  end
  
  
end