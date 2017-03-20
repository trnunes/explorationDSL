require './test/xpair_unit_test'

class RefineTest < XpairUnitTest

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
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), 2005]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), 2010]
      
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
  
  
  def test_refine_equal
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.refine{|f| f.equals(values: Entity.new("_:p2"))}
    
    expected_extension = { 
      Entity.new("_:p2") => {}
    }   
    
    assert_equal expected_extension, relation.extension
  end
  
  def test_refine_equal_two_steps
    set = Xset.new do |s| 
      s << Entity.new("_:p1") 
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set2 = Xset.new do |s| 
      s << Entity.new("_:a1")
      s << Entity.new("_:a2")
      
      s.relation_index = {
        Entity.new("_:p1") => {Entity.new("_:a1")=>{}},
        Entity.new("_:p2") => {Entity.new("_:a1")=>{}},
        Entity.new("_:p3") => {Entity.new("_:a2")=>{}}
      }
      s.resulted_from = set
    end
    
    expected_extension = {
      Entity.new("_:p1") => {},
      Entity.new("_:p2") => {}
    }
    
    rs = set.refine{|rf| rf.image_equals(relations: [set2], values: Entity.new("_:a1"))}
    assert_equal expected_extension, rs.extension
  end
  
  def test_refine_equal_three_steps
    set = Xset.new do |s| 
      s << Entity.new("_:p1") 
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set2 = Xset.new do |s| 
      s << Entity.new("_:a1")
      s << Entity.new("_:a2")
      s << Entity.new("_:a3")
      s << Entity.new("_:a4")
      
      s.relation_index = {
        Entity.new("_:p1") => {Xsubset.new(set, 1){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a2")=>{}}}=>{}},
        Entity.new("_:p2") => {Xsubset.new(set, 1){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a3")=>{}}}=>{}},
        Entity.new("_:p3") => {Xsubset.new(set, 1){|s| s.extension = {Entity.new("_:a4")=>{}}}=>{}}
      }
      s.resulted_from = set
    end
    
    set3 = Xset.new do |s| 
      s << Xpair::Literal.new(2)
      s << Xpair::Literal.new(2)
      s << Xpair::Literal.new(1)
      
      s.relation_index = {
        Xsubset.new(set2, 1) do |s|
          s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a2")=>{}} 
        end => {Xpair::Literal.new(2)=>{}},
        Xsubset.new(set2, 1) do |s|
          s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a3")=>{}}
        end => {Xpair::Literal.new(2)=>{}},
        Xsubset.new(set2, 1) do |s|
          s.extension = {Entity.new("_:a4")=>{}}
        end => {Xpair::Literal.new(1)=>{}},
      }
      s.resulted_from = set2
    end

    expected_extension = {
      Entity.new("_:p1") => {},
      Entity.new("_:p2") => {}
    }
    
    rs = set.refine{|rf| rf.image_equals(relations: [set2, set3], values: Xpair::Literal.new("2"))}
    assert_equal expected_extension, rs.extension
  end

  
  def test_refine_equal_literal
    set = Xset.new do |s| 
      s << Entity.new("_:journal1")
      s << Entity.new("_:journal2")

    end
    
    set.server = @papers_server
    
    relation = set.refine{|f| f.equals(relations: [Entity.new("_:releaseYear")], values: "2005")}
    
    expected_extension = { 
      Entity.new("_:journal1") => {}
    }   
    
    assert_equal expected_extension, relation.extension
    
  end

  def test_refine_match
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
      s << Entity.new("_:o3")
    end
    
    set.server = @server
    
    relation = set.refine{|f| f.match(values: "_:p")}
    
    expected_extension = { 
      Entity.new("_:p1")=>{},
      Entity.new("_:p2")=>{},
      Entity.new("_:p3")=>{},      
    }   
    
    assert_equal expected_extension, relation.extension
  end
  
  def test_search_refine
    set = Xset.new do |s|
      @papers_server.search(["p"]).each do |item|      
        s << item     
      end
      s.server = @papers_server
    end
    set.save
    rs = Xset.load(set.id).refine{|f|f.equals(relations: [Relation.new('_:cite')],values: Entity.new('_:p3'),)}
    expected_extension = { 
      Entity.new("_:paper1") => {},
      Entity.new("_:p6") => {},
      Entity.new("_:p7") => {},
      Entity.new("_:p8") => {}
    }    
    
    assert_equal expected_extension, rs.extension
    
  end

  def test_refine_relation_equal
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.refine{|f| f.equals(relations: [Relation.new("_:r1")], values: Entity.new("_:o2"))}
    
    expected_extension = { 
     Entity.new("_:p1") => {},
     Entity.new("_:p2") => {}      
    }    
    
    assert_equal expected_extension, relation.extension
  end
  
  def test_refine_relation_match
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.refine{|f| f.match relations: [Relation.new("_:r1")], values: "2" }
    
    expected_extension = { 
     Entity.new("_:p1") => {},
     Entity.new("_:p2") => {}      
    }    
    assert_equal expected_extension, relation.extension
  end
  
  def test_refine_keyword_match
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:journal1")
      s << Entity.new("_:journal2")
    end
    
    set.server = @papers_server
    
    relation = set.refine{|f| f.keyword_match(keywords: ['journal',])}
    
    expected_extension = { 
      Entity.new("_:p2") => {},
      Entity.new("_:journal1") => {},
      Entity.new("_:journal2") => {}      
    }    
    assert_equal expected_extension, relation.extension
    
  end
  
  def test_refine_keyword_conjunctive
    set = Xset.new do |s|
      s.server = @server
    end
    
    expected_extension = { 
     Entity.new("_:p1") => {},
     Entity.new("_:p2") => {}      
    }    
  end
  
  def test_select
    set = Xset.new do |s|
      s.extension = {
        Relation.new("_:author") => {Entity.new("_:a1")=>{}},
        Relation.new("_:publishedOn") => {Entity.new("_:journal1")=>{}},
        Relation.new("_:publicationYear") => {Xpair::Literal.new(2000)=>{}},
        Relation.new("_:keywords") => {Entity.new("_:k3")=>{}},
        Relation.new("_:cite", true) => {Entity.new("_:paper1")=>{}, Entity.new("_:p6")=>{}}
      }      
    
    end
    expected_extension = {
      Entity.new("_:a1") => {},
      Relation.new("_:author") => {}
    }
    assert_equal expected_extension, set.select([Entity.new("_:a1"), Relation.new("_:author")]).extension
    expected_extension = {
      Relation.new("_:cite", true) => {},
    }
    assert_equal expected_extension, set.select([Relation.new("_:cite", true)]).extension
    expected_extension = { }
    assert_equal expected_extension, set.select([Entity.new("strange_item")]).extension
    
  end
  def test_select_2
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
    assert_equal set.group{|gf| gf.by_relation(Relation.new("_:author"))}.extension.keys.size, 2
    assert !set.group{|gf| gf.by_relation(Relation.new("_:author"))}.select([Entity.new("_:p2")]).extension.empty?
  end
  
  # def test_get_item
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Relation.new("_:author") => {Entity.new("_:a1")=>{}},
  #       Relation.new("_:publishedOn") => {Entity.new("_:journal1")=>{}},
  #       Relation.new("_:publicationYear") => {Xpair::Literal.new(2000)=>{}},
  #       Relation.new("_:keywords") => {Entity.new("_:k3")=>{}},
  #       Relation.new("_:cite", true) => {Entity.new("_:paper1")=>{}, Entity.new("_:p6")=>{}}
  #     }
  #
  #   end
  #   assert_equal Entity.new("_:a1"), set.get_item(Entity.new("_:a1"))
  #   assert_equal Entity.new("_:k3"), set.get_item(Entity.new("_:k3"))
  #   assert_equal Xpair::Literal.new(2000), set.get_item(Xpair::Literal.new(2000))
  #   assert_equal Relation.new("_:cite", true), set.get_item(Relation.new("_:cite", true))
  #
  # end
   
  
end