
require './test/xpair_unit_test'

class MultilevelXsetTest < XpairUnitTest

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
  
  def test_get_level
    origin_set = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{Entity.new("_:w1")=>{}}}}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{Entity.new("_:w2")=>{}}}}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>{Entity.new("_:t3")=>{Entity.new("_:w3")=>{}}}}
    end
    expected_level_1 = Set.new([origin_set.extension])
    expected_level_3 = Set.new([
      {Entity.new("_:t1")=>{Entity.new("_:w1")=>{}}}, 
      {Entity.new("_:t2")=>{Entity.new("_:w2")=>{}}}, 
      {Entity.new("_:t3")=>{Entity.new("_:w3")=>{}}}
    ])
    expected_level_4 = Set.new([
      {Entity.new("_:w1")=>{}},
      {Entity.new("_:w2")=>{}},
      {Entity.new("_:w3")=>{}}      
    ])
    assert_equal  expected_level_1, origin_set.select_level(1)
    assert_equal  expected_level_3, origin_set.select_level(3)
    assert_equal  expected_level_4, origin_set.select_level(4)
  end
  
  def test_each_level
    origin_set = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{Entity.new("_:w1")=>{}}}}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{Entity.new("_:w2")=>{}}}}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>{Entity.new("_:t3")=>{Entity.new("_:w3")=>{}}}}
    end
    expected_level_1 = Set.new([ origin_set.extension])
    expected_level_3 = Set.new([
      {Entity.new("_:t1")=>{Entity.new("_:w1")=>{}}}, 
      {Entity.new("_:t2")=>{Entity.new("_:w2")=>{}}}, 
      {Entity.new("_:t3")=>{Entity.new("_:w3")=>{}}}
    ])
    expected_level_4 = Set.new([
      {Entity.new("_:w1")=>{}},
      {Entity.new("_:w2")=>{}},
      {Entity.new("_:w3")=>{}}      
    ])
    
    level = 0
    origin_set.each_level do |items|


        
      assert_equal  expected_level_1, items if level == 0

      assert_equal  expected_level_3, items if level == 2
      assert_equal  expected_level_4, items if level == 3
      level += 1      
    end
    assert_equal level, 4
  end
  
  def test_get_number_of_levels
    origin_set = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>{Entity.new("_:t1")=>{Entity.new("_:w1")=>{}}}}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>{Entity.new("_:t2")=>{Entity.new("_:w2")=>{}}}}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>{Entity.new("_:t3")=>{Entity.new("_:w3")=>{}}}}
    end
    assert_equal 4, origin_set.count_levels
  end
  
  def test_count_levels_2
    origin_set = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {}
      s.extension[Entity.new("_:i2")]= {}
      s.extension[Entity.new("_:i3")]= {}
    end
    assert_equal 1, origin_set.count_levels
  end
  
  
  
  def test_each_level2
    set = Xset.new do |s|
      s.extension = {
        Relation.new("_:cite") => {Entity.new("_:p3")=> {},Entity.new("_:p4")=> {}}
      }      
    
    end
    set.get_level(2)
    set.server = @papers_server
    assert_equal set.get_level(1).first.keys.size, 1
    assert_equal set.get_level(2).first.keys.size, 2
  end
  
  
  
end