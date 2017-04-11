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
  
  def test_map_empty
    set = Xset.new
    set.map{|mf|mf.count}.empty?
    set.map{|mf| mf.avg([Xset.new, Xset.new])}.empty?
  end
  
  def test_map_level3
    subset1 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p3") => {},Entity.new("_:p4") => {}}}
    subset2 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p2") => {}}}
    subset3 = Xsubset.new("key"){|s| s.extension = {Relation.new("_:cite") => subset1}}
    subset4 = Xsubset.new("key"){|s| s.extension = {Relation.new("_:cite") => subset2}}
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:paper1")=>subset3,
        Entity.new("_:p5")=>subset4
      }      
    
    end
    set.server = @papers_server
    h1 = {
      subset1=>Xsubset.new("Key"){|s| s.extension = {subset1 => {Xpair::Literal.new(2) => {}}}},
      subset2=>Xsubset.new("Key"){|s| s.extension = {subset2 => {Xpair::Literal.new(1) => {}}}}
    }
    
    
    assert_equal h1, set.map{|mf|mf.count}.extension
    
  end
  
  def test_map_image_count

    target_set = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= Xsubset.new("key"){|s| s.extension ={Entity.new("_:r")=>Xsubset.new("key"){|s| s.extension ={Entity.new("_:u1")=>{}}}}}
      s.extension[Entity.new("_:t2")]= Xsubset.new("key"){|s| s.extension ={Entity.new("_:r")=>Xsubset.new("key"){|s| s.extension ={Entity.new("_:u2")=>{}}}}}
      s.extension[Entity.new("_:t3")]= Xsubset.new("key"){|s| s.extension ={Entity.new("_:r")=>Xsubset.new("key"){|s| s.extension ={Entity.new("_:u3")=>{}}}}}
      s.extension[Entity.new("_:t4")]= Xsubset.new("key"){|s| s.extension ={Entity.new("_:r")=>Xsubset.new("key"){|s| s.extension ={Entity.new("_:u4")=>{}}}}}

    end
    
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= Xsubset.new("key"){|s| s.extension = {Entity.new("_:r")=>Xsubset.new("key")  {|s| s.extension ={Entity.new("_:t1")=>{}}}}}
      s.extension[Entity.new("_:i2")]= Xsubset.new("key"){|s| s.extension = {Entity.new("_:r")=>Xsubset.new("key")  {|s| s.extension ={Entity.new("_:t2")=>{}}}}}
      s.extension[Entity.new("_:i3")]= Xsubset.new("key"){|s| s.extension = {Entity.new("_:r")=>Xsubset.new("key")  {|s| s.extension ={Entity.new("_:t1")=>{}, Entity.new("_:t3")=>{}}}}}
      s.extension[Entity.new("_:i4")]= Xsubset.new("key"){|s| s.extension = {Entity.new("_:r")=>Xsubset.new("key")  {|s| s.extension ={Entity.new("_:t1")=>{}, Entity.new("_:t4")=>{}}}}}
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
  
  def test_average
    set = Xset.new do |s|
      s.extension = {
        Xpair::Literal.new(1)=>{},
        Xpair::Literal.new(2)=>{},
        Xpair::Literal.new(3)=>{},
        Xpair::Literal.new(4)=>{}
      }
      s.server = @papers_server
    end
    rs = set.map{|mf| mf.avg}    
    expected_extension = {set => {Xpair::Literal.new(2.5)=>{}}}
    assert_equal expected_extension, rs.extension
  end
  
  def test_average_relations
    subset1 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:o1") =>Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(20)=>{}}},
        Entity.new("_:o2") =>Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(30)=>{}}}
      }
    end
    subset2 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:o1") =>Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(40)=>{}}},
        Entity.new("_:o2") =>Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(50)=>{}}}
      }
    end
    subset3 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:r") => subset1
      }
    end
    
    subset4 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:r") => subset2
      }
    end
    
    target_set = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= subset3
      s.extension[Entity.new("_:t2")]= subset4
    end
    
    subset5 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:t1") => {}
      }
    end
    subset6 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:t2") => {}
      }
    end
    
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= subset5
      s.extension[Entity.new("_:i2")]= subset6
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
    end
    
    rs = origin_set.map{|mf| mf.avg([mid_set_1, target_set])}
    
    expected_extension = {
      Entity.new("_:i1")=>{Xpair::Literal.new(25.0)=>{}},
      Entity.new("_:i2")=>{Xpair::Literal.new(45.0)=>{}}
    }
    assert_equal expected_extension, rs.extension

  end

end

def test_average_level3
  expected_index = {
    Entity.new("_:t1") => {
      Xsubset.new(target_set) do |s| 
        s.extension = {
            Entity.new("_:o1") =>{Xpair::Literal.new(20)=>{}},
            Entity.new("_:o2") =>{Xpair::Literal.new(30)=>{}}
        }
      end => {Xpair::Literal.new(25.0)=>{}}        
    },
    Entity.new("_:t2") => {
      Xsubset.new(target_set) do |s|
        s.extension = {
          Entity.new("_:o1") =>{Xpair::Literal.new(40)=>{}},
          Entity.new("_:o2") =>{Xpair::Literal.new(50)=>{}}
        }
      end => {Xpair::Literal.new(45.0)=>{}}
      
    },
  }
  
end