require './test/xpair_unit_test'

class MapTest < XpairUnitTest

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
  
  def test_map_level3
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1")=>{Relation.new("_:cite") => {Entity.new("_:p3") => {},Entity.new("_:p4") => {}}},
        Entity.new("_:p5")=>{Relation.new("_:cite") => {Entity.new("_:p2")=>{}}}
      }      
    
    end
    set.server = @papers_server
    h1 = {
      Entity.new("_:paper1")=>{Relation.new("_:cite")=>{Xpair::Literal.new(2) => {}}},
      Entity.new("_:p5")=>{Relation.new("_:cite")=>{Xpair::Literal.new(1) => {}}}
    }
    
    expected_index = {
      Xsubset.new(set, 3) do |s|
        s.extension = {Entity.new("_:p3") => {},Entity.new("_:p4") => {}}
      end => {Xpair::Literal.new(2) => {}},
      Xsubset.new(set, 3) do |s|
        s.extension = {Entity.new("_:p2")=>{}}
      end => {Xpair::Literal.new(1) => {}},
      
    }
    
    assert_equal h1, set.map(level: 3){|mf|mf.count}.extension
    
  end
  
  def test_map_image_count
    target_set = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= {Entity.new("_:r")=>{Entity.new("_:u1")=>{}}}
      s.extension[Entity.new("_:t2")]= {Entity.new("_:r")=>{Entity.new("_:u2")=>{}}}
      s.extension[Entity.new("_:t3")]= {Entity.new("_:r")=>{Entity.new("_:u3")=>{}}}
      s.extension[Entity.new("_:t4")]= {Entity.new("_:r")=>{Entity.new("_:u4")=>{}}}
      s.relation_index = {
        Entity.new("_:t1") => {Entity.new("_:u1")=>{}},
        Entity.new("_:t2") => {Entity.new("_:u2")=>{}},
        Entity.new("_:t3") => {Entity.new("_:u3")=>{}},
        Entity.new("_:t4") => {Entity.new("_:u4")=>{}}
      }

    end
    
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}}}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{}}}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t3")=>{}}}
      s.extension[Entity.new("_:i4")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}, Entity.new("_:t4")=>{}}}
      s.relation_index = {
        Entity.new("_:i1") => {Entity.new("_:t1")=>{}},
        Entity.new("_:i2") => {Entity.new("_:t2")=>{}},
        Entity.new("_:i3") => {
          Entity.new("_:t1")=>{},
          Entity.new("_:t3")=>{}
        },
        Entity.new("_:i4") => {
          Entity.new("_:t1")=>{},
          Entity.new("_:t4")=>{}
        }
      }
      
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
      s << Entity.new("_:i3")
      s << Entity.new("_:i4")
    end
    mid_set_1.resulted_from = origin_set
    target_set.resulted_from = mid_set_1
    rs = origin_set.map{|mf| mf.image_count([target_set, mid_set_1])}

    expected_extension = {
      Entity.new("_:i1")=>{Xpair::Literal.new(1)=>{}},
      Entity.new("_:i2")=>{Xpair::Literal.new(1)=>{}},
      Entity.new("_:i3")=>{Xpair::Literal.new(2)=>{}},
      Entity.new("_:i4")=>{Xpair::Literal.new(2)=>{}}
    }
    assert_equal expected_extension, rs.extension
  end
  
  def test_average_relations
    target_set = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= {
        Entity.new("_:r")=>{
          Entity.new("_:o1") =>{Xpair::Literal.new(20)=>{}},
          Entity.new("_:o2") =>{Xpair::Literal.new(30)=>{}}
        }
      }
      s.extension[Entity.new("_:t2")]= {
        Entity.new("_:r")=>{
          Entity.new("_:o1") =>{Xpair::Literal.new(40)=>{}},
          Entity.new("_:o2") =>{Xpair::Literal.new(50)=>{}}
        }
      }
      s.relation_index = {
        Entity.new("_:t1") => {
          Entity.new("_:r")=>{
            Entity.new("_:o1") =>{Xpair::Literal.new(20)=>{}},
            Entity.new("_:o2") =>{Xpair::Literal.new(30)=>{}}
          }          
        },
        Entity.new("_:t2") => {
          Entity.new("_:r")=>{
            Entity.new("_:o1") =>{Xpair::Literal.new(40)=>{}},
            Entity.new("_:o2") =>{Xpair::Literal.new(50)=>{}}
          }          
        }        
      }
      
    end
    
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{}}}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{}}}
      s.relation_index = {
        Entity.new("_:i1") => {Entity.new("_:t1")=>{}},
        Entity.new("_:i2") => {Entity.new("_:t2") =>{}}
      }
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
    end
    rs = origin_set.map{|mf| mf.avg([mid_set_1, target_set])}
    expected_extension = {
      Entity.new("_:i1")=>{Xpair::Literal.new(25.0)=>{}},
      Entity.new("_:i2")=>{Xpair::Literal.new(45.0)=>{}},
    }
    
    expected_index = {
      Entity.new("_:i1")=>{Xpair::Literal.new(25.0)=>{}},
      Entity.new("_:i2")=>{Xpair::Literal.new(45.0)=>{}}
    }
    assert_equal expected_extension, rs.extension
    assert_equal expected_index, rs.relation_index
  end

end

def test_average_level3
  expected_index = {
    Entity.new("_:t1") => {
      Xsubset.new(target_set, 1) do |s| 
        s.extension = {
            Entity.new("_:o1") =>{Xpair::Literal.new(20)=>{}},
            Entity.new("_:o2") =>{Xpair::Literal.new(30)=>{}}
        }
      end => {Xpair::Literal.new(25.0)=>{}}        
    },
    Entity.new("_:t2") => {
      Xsubset.new(target_set, 1) do |s|
        s.extension = {
          Entity.new("_:o1") =>{Xpair::Literal.new(40)=>{}},
          Entity.new("_:o2") =>{Xpair::Literal.new(50)=>{}}
        }
      end => {Xpair::Literal.new(45.0)=>{}}
      
    },
  }
  
end