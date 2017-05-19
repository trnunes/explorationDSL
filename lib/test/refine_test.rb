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
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), RDF::Literal.new(2005)]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), RDF::Literal.new(2010)]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), RDF::Literal.new(2000)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), RDF::Literal.new(1998)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), RDF::Literal.new(2010)]     
    end

    @papers_server = RDFDataServer.new(papers_graph)
      
  end
  
  def test_refine_empty
    set = Xset.new("test", "")
    set.server = @papers_server
    
    assert_true set.refine{|f| f.equals(values: [Entity.new("_:p2")])}.empty?
    # assert_true set.refine{|rf| rf.image_equals(relations: [ComputedRelation.new("test")], values: [Entity.new("_:a1")])}.empty?
    assert_true set.refine{|f| f.match(values: "_:p")}.empty?
    assert_true set.refine{|f| f.keyword_match(keywords: ['journal',])}.empty?
    # assert_true set.select_items([Entity.new("_:a1"), SchemaRelation.new("_:author", @papers_server)]).empty?
  end
  
  # def test_refine_equal
  #   set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #   end
  #
  #   set.server = @server
  #
  #   relation = set.refine{|f| f.equals(values: Entity.new("_:p2"))}
  #
  #   expected_extension = {
  #     Entity.new("_:p2") => {}
  #   }
  #
  #   assert_equal expected_extension, relation.extension
  # end
  
  # def test_refine_equal_two_steps
  #   set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #   end
  #
  #   set2 = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => {Entity.new("_:a1")=>{}},
  #       Entity.new("_:p2") => {Entity.new("_:a1")=>{}},
  #       Entity.new("_:p3") => {Entity.new("_:a2")=>{}}
  #     }
  #     s.resulted_from = set
  #   end
  #
  #   expected_extension = {
  #     Entity.new("_:p1") => {},
  #     Entity.new("_:p2") => {}
  #   }
  #
  #   rs = set.refine{|rf| rf.image_equals(relations: [set2], values: Entity.new("_:a1"))}
  #   assert_equal expected_extension, rs.extension
  # end
  
  # def test_refine_equal_three_steps
  #   set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #   end
  #   set.save
  #   set2 = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a2")=>{}}},
  #       Entity.new("_:p2") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a3")=>{}}},
  #       Entity.new("_:p3") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a4")=>{}}}
  #     }
  #     s.resulted_from = set
  #   end
  #   set2.save
  #
  #   set3 = Xset.new do |s|
  #     s.extension = {
  #       Xsubset.new("key") do |s|
  #         s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a2")=>{}}
  #       end => {Xpair::Literal.new(2)=>{}},
  #       Xsubset.new("key") do |s|
  #         s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a3")=>{}}
  #       end => {Xpair::Literal.new(2)=>{}},
  #       Xsubset.new("key") do |s|
  #         s.extension = {Entity.new("_:a4")=>{}}
  #       end => {Xpair::Literal.new(1)=>{}},
  #     }
  #     s.resulted_from = set2
  #   end
  #   set3.save
  #
  #   expected_extension = {
  #   Entity.new("_:p1") => {},
  #   Entity.new("_:p2") => {}
  #   }
  #
  #   rs = set.refine{|rf| rf.image_equals(relations: [set2, set3], values: Xpair::Literal.new("2"))}
  #   assert_equal expected_extension, rs.extension
  # end

  # def test_refine_subsets
  #   set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #   end
  #   set.save
  #   set2 = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a2")=>{}}},
  #       Entity.new("_:p2") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a3")=>{}}},
  #       Entity.new("_:p3") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a4")=>{}}}
  #     }
  #     s.resulted_from = set
  #   end
  #   set2.save
  #
  #   set3 = Xset.new do |s|
  #     s.extension = {
  #       Xsubset.new("key") do |s|
  #         s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a2")=>{}}
  #       end => {Xpair::Literal.new(2)=>{}},
  #       Xsubset.new("key") do |s|
  #         s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a3")=>{}}
  #       end => {Xpair::Literal.new(2)=>{}},
  #       Xsubset.new("key") do |s|
  #         s.extension = {Entity.new("_:a4")=>{}}
  #       end => {Xpair::Literal.new(1)=>{}},
  #     }
  #     s.resulted_from = set2
  #   end
  #   set3.save
  #
  #   expected_extension = {
  #     Entity.new("_:p1") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a2")=>{}}},
  #     Entity.new("_:p2") => Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1")=>{}, Entity.new("_:a3")=>{}}},
  #   }
  #   rs = set2.refine{|rf| rf.image_equals(relations: [set3], values: Xpair::Literal.new("2"))}
  #   assert_equal expected_extension, rs.extension
  # end
  
  def test_refine_equal_literal
    set = Xset.new("test", "")

    set.add_item Entity.new("_:journal1")
    set.add_item Entity.new("_:journal2")
    
    set.server = @papers_server
    
    relation = set.refine{|f| f.equals(relations: [SchemaRelation.new("_:releaseYear", @papers_server)], values: "2005")}
    # expected_pairs = [Pair.new(Entity.new("_:journal1"), Entity.new("_:journal1"), 'default')]
    index = Entry.new('root')

    puts relation.inspect
    
    # assert_equal Set.new(expected_pairs), Set.new(relation.each_relation.first.each_pair)
    
  end

  # def test_refine_match
  #   set = Xset.new("test", "")
  #
  #   set.add_pair Pair.new(Entity.new("_:p1"), Entity.new("_:p1"))
  #   set.add_pair Pair.new(Entity.new("_:p2"), Entity.new("_:p2"))
  #   set.add_pair Pair.new(Entity.new("_:p3"), Entity.new("_:p3"))
  #   set.add_pair Pair.new(Entity.new("_:o3"), Entity.new("_:o3"))
  #
  #   set.server = @server
  #
  #   relation = set.refine{|f| f.match(values: "_:p")}
  #
  #   expected_pairs = Set.new([
  #     Pair.new(Entity.new("_:p1"), Entity.new("_:p1"), 'default'),
  #     Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default'),
  #     Pair.new(Entity.new("_:p3"), Entity.new("_:p3"), 'default')
  #   ])
  #
  #   assert_equal expected_pairs, Set.new(relation.each_relation.first.each_pair)
  # end
  
  # def test_search_refine
  #   set = Xset.new do |s|
  #     @papers_server.search(["p"]).each do |item|
  #       s << item
  #     end
  #     s.server = @papers_server
  #   end
  #   set.save
  #   rs = Xset.load(set.id).refine{|f|f.equals(relations: [Relation.new('_:cite')],values: Entity.new('_:p3'),)}
  #   expected_extension = {
  #     Entity.new("_:paper1") => {},
  #     Entity.new("_:p6") => {},
  #     Entity.new("_:p7") => {},
  #     Entity.new("_:p8") => {}
  #   }
  #
  #   assert_equal expected_extension, rs.extension
  #
  # end

  def test_refine_relation_equal
    set = Xset.new('test', '')
    
    set.add_item Entity.new("_:p1")
    set.add_item Entity.new("_:p2")
    set.add_item Entity.new("_:p3")
    
    
    set.server = @server
    
    relation = set.refine{|f| f.equals(relations: [SchemaRelation.new("_:r1", @papers_server)], values: Entity.new("_:o2"))}
      #
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:p1"), Entity.new("_:p1"), 'default'),
    #   Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default')
    #
    # ])
    
    # assert_equal expected_pairs, Set.new(relation.each_relation.first.each_pair)
    puts relation.inspect
  end
  
  # def test_refine_relation_equal_AND
  #   set = Xset.new('test', '')
  #
  #   set.add_pair Pair.new(Entity.new("_:paper1"), Entity.new("_:paper1"))
  #   set.add_pair Pair.new(Entity.new("_:p2"), Entity.new("_:p2"))
  #   set.add_pair Pair.new(Entity.new("_:p5"), Entity.new("_:p5"))
  #
  #
  #   set.server = @papers_server
  #
  #   relation = set.refine{|f| f.image_equals(relations: [set.pivot_forward(relations: [SchemaRelation.new("_:author", @papers_server)])], values: [Entity.new("_:a1"), Entity.new("_:a2")])}
  #
  #   expected_pairs = Set.new([
  #     Pair.new(Entity.new("_:paper1"), Entity.new("_:paper1"), 'default'),
  #     Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default')
  #   ])
  #
  #   assert_equal expected_pairs, Set.new(relation.each_relation.first.each_pair)
  # end
  #
  # def test_refine_relation_equal_OR
  #   set = Xset.new do |s|
  #     s << Entity.new("_:paper1")
  #     s << Entity.new("_:p10")
  #     s << Entity.new("_:p5")
  #   end
  #
  #   set.server = @papers_server
  #
  #   relation = set.refine{|f| f.image_equals(relations: [set.pivot_forward(relations: [Relation.new("_:author")])], values: [Entity.new("_:a1"), Entity.new("_:a2")], connector: "OR")}
  #
  #   expected_extension = {
  #    Entity.new("_:paper1") => {},
  #    Entity.new("_:p5") => {}
  #   }
  #
  #   assert_equal expected_extension, relation.extension
  # end
  #
  
  def test_refine_relation_match
    set = Xset.new('test', '')
    
    set.add_item Entity.new("_:p1")
    set.add_item Entity.new("_:p2")
    set.add_item Entity.new("_:p3")
    
    
    set.server = @server
    
    relation = set.refine{|f| f.match relations: [SchemaRelation.new("_:r1", @papers_server)], values: "2" }
    
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:p1"), Entity.new("_:p1"), 'default'),
    #   Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default'),
    #   Pair.new(Entity.new("_:p3"), Entity.new("_:p3"), 'default'),
    #
    # ])
    # assert_equal expected_pairs, Set.new(relation.each_relation.first.each_pair)
    puts relation.inspect
  end
  
  def test_refine_equal_disjunctive_values
    set = Xset.new('test', '')
    
    set.add_item Entity.new("_:paper1")
    set.add_item Entity.new("_:p10")
    set.add_item Entity.new("_:p5")
    
    
    set.server = @papers_server
    
    relation = set.refine{|f| f.equals(relations: [SchemaRelation.new("_:author", @papers_server)], values: [Entity.new("_:a1"), Entity.new("_:a2")], connector: "OR")}
    
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:paper1"), Entity.new("_:paper1"), 'default'),
    #   Pair.new(Entity.new("_:p5"), Entity.new("_:p5"), 'default')
    # ])
    #
    # assert_equal expected_pairs, Set.new(relation.each_relation.first.each_pair)
    puts relation.inspect
    
  end
  
  def test_refine_equal_conjunctive_values
    set = Xset.new('test', '')
    
    set.add_item Entity.new("_:paper1")
    set.add_item Entity.new("_:p5")
    set.add_item Entity.new("_:p10")
    set.add_item Entity.new("_:p3")
    set.add_item Entity.new("_:p2")
    
    
    set.server = @papers_server
    
    relation = set.refine{|f| f.equals(relations: [SchemaRelation.new("_:author", @papers_server)], values: [Entity.new("_:a1"), Entity.new("_:a2")], connector: 'AND')}
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:paper1"), Entity.new("_:paper1"), 'default'),
    #   Pair.new(Entity.new("_:p5"), Entity.new("_:p5"), 'default')
    # ])
    #
    # assert_equal expected_pairs, Set.new(relation.each_relation.first.each_pair)
    relation.inspect    
  end

  def test_refine_equal_property_path
    set = Xset.new('test', '')
    
    set.add_item Entity.new("_:paper1")
    set.add_item Entity.new("_:p5")
    set.add_item Entity.new("_:p6")
    set.add_item Entity.new("_:p8")
    set.add_item Entity.new("_:p7")
    set.add_item Entity.new("_:p9")
    set.add_item Entity.new("_:p10")
    set.add_item Entity.new("_:p3")
    set.add_item Entity.new("_:p2")
    
    
    set.server = @papers_server
    
    relation = set.refine{|f|f.equals(connector: 'AND',relations: [PathRelation.new([SchemaRelation.new('_:publishedOn', @papers_server), SchemaRelation.new('_:releaseYear', @papers_server)])], values: [Xpair::Literal.new('2005')],)}
    
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default')
    # ])
    #
    # assert_equal expected_pairs, Set.new(relation.each_relation.first.each_pair)
    puts relation.inspect
    
  end
  
  
  # def test_refine_keyword_match
  #   set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:journal1")
  #     s << Entity.new("_:journal2")
  #   end
  #
  #   set.server = @papers_server
  #
  #   relation = set.refine{|f| f.keyword_match(keywords: ['journal',])}
  #
  #   expected_extension = {
  #     Entity.new("_:journal1") => {},
  #     Entity.new("_:journal2") => {}
  #   }
  #   assert_equal expected_extension, relation.extension
  #
  # end
  #
  # def test_refine_keyword_conjunctive
  #   set = Xset.new do |s|
  #     s.server = @server
  #   end
  #
  #   expected_extension = {
  #    Entity.new("_:p1") => {},
  #    Entity.new("_:p2") => {}
  #   }
  # end
  #
  # def test_select
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Relation.new("_:author") =>          Xsubset.new("key"){|s| s.extension = {Entity.new("_:a1")=>{}}},
  #       Relation.new("_:publishedOn") =>     Xsubset.new("key"){|s| s.extension = {Entity.new("_:journal1")=>{}}},
  #       Relation.new("_:publicationYear") => Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2000)=>{}}},
  #       Relation.new("_:keywords") =>        Xsubset.new("key"){|s| s.extension = {Entity.new("_:k3")=>{}}},
  #       Relation.new("_:cite", true) =>      Xsubset.new("key"){|s| s.extension = {Entity.new("_:paper1")=>{}, Entity.new("_:p6")=>{}}}
  #     }
  #
  #   end
  #   expected_extension = {
  #     Entity.new("_:a1") => {},
  #     Relation.new("_:author") => {}
  #   }
  #   assert_equal expected_extension, set.select_items([Entity.new("_:a1"), Relation.new("_:author")]).extension
  #   expected_extension = {
  #     Relation.new("_:cite", true) => {},
  #   }
  #   assert_equal expected_extension, set.select_items([Relation.new("_:cite", true)]).extension
  #   expected_extension = { }
  #   assert_equal expected_extension, set.select_items([Entity.new("strange_item")]).extension
  #
  # end
  # def test_select_2
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => {},
  #       Entity.new("_:p2") => {},
  #       Entity.new("_:p3") => {},
  #       Entity.new("_:p4") => {},
  #       Entity.new("_:p5") => {},
  #       Entity.new("_:p6") => {},
  #       Entity.new("_:paper1") => {}
  #     }
  #   end
  #   set.server = @papers_server
  #   assert_equal set.group{|gf| gf.by_relation(relations: [Relation.new("_:author")])}.extension.keys.size, 2
  #   assert !set.group{|gf| gf.by_relation(relations: [Relation.new("_:author")])}.select_items([Entity.new("_:p2")]).extension.empty?
  # end
  
  # def test_union_image_equals
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => {},
  #       Entity.new("_:p2") => {},
  #       Entity.new("_:p3") => {},
  #       Entity.new("_:p4") => {},
  #       Entity.new("_:p5") => {},
  #       Entity.new("_:p6") => {},
  #       Entity.new("_:paper1") => {}
  #     }
  #   end
  #   set.server = @papers_server
  #   s1 = set.select_items([Entity.new("_:p3")])
  #   s2 = set.select_items([Entity.new("_:p2")])
  #   # binding.pry
  #   union = s1.union(s2)
  #   p = union.pivot_forward(relations: [Relation.new('_:publicationYear')])
  #
  #   rs = union.refine{|f| f.image_equals(relations: [p],values: Xpair::Literal.new('2000', 'http://www.w3.org/2001/XMLSchema#integer'),)}
  #   expected_extension = {
  #     Entity.new("_:p2") => {}
  #   }
  #   assert_equal expected_extension, rs.extension
  # end
  #
  # def test_union_equals
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => {},
  #       Entity.new("_:p2") => {},
  #       Entity.new("_:p3") => {},
  #       Entity.new("_:p4") => {},
  #       Entity.new("_:p5") => {},
  #       Entity.new("_:p6") => {},
  #       Entity.new("_:paper1") => {}
  #     }
  #   end
  #   set.server = @papers_server
  #   s1 = set.select_items([Entity.new("_:p3")])
  #   s2 = set.select_items([Entity.new("_:p2")])
  #   union = s1.union(s2)
  #   p = union.pivot_forward(relations: [Relation.new('_:publicationYear')])
  #
  #   rs = union.refine{|f| f.equals(relations: [Relation.new("_:publicationYear")],values: Xpair::Literal.new('2000', 'http://www.w3.org/2001/XMLSchema#integer'),)}
  #   expected_extension = {
  #     Entity.new("_:p2") => {}
  #   }
  #   assert_equal expected_extension, rs.extension
  # end
  
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
   
  # def test_pivot_flatten_refine
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => Entity.new("_:p1"),
  #       Entity.new("_:p2") => Entity.new("_:p2"),
  #       Entity.new("_:p3") => Entity.new("_:p3"),
  #       Entity.new("_:p4") => Entity.new("_:p4"),
  #       Entity.new("_:p5") => Entity.new("_:p5"),
  #       Entity.new("_:p6") => Entity.new("_:p6"),
  #       Entity.new("_:paper1") => Entity.new("_:paper1")
  #     }
  #   end
  #   set.server = @papers_server
  #   set.id= "sorigin"
  #
  #   s1 = set.pivot_forward(relations: [Relation.new("_:publicationYear")]);
  #   s1.id = "s1"
  #   s2 = s1.flatten
  #   s2.id = "flatten"
  #   s3 = set.refine{|f| f.image_equals(relations: [s2], values: Xpair::Literal.new("1998"))}
  # end
  #
  # def test_refine_in_range
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p2") => {},
  #       Entity.new("_:p3") => {},
  #       Entity.new("_:p4") => {},
  #     }
  #   end
  #   set.server = @papers_server
  #   rs = set.refine{|f| f.in_range(relations: [Relation.new("_:publicationYear")], min: Xpair::Literal.new(1997.0), max: Xpair::Literal.new(2005.0))}
  #   expected_rs = {
  #     Entity.new("_:p2") => {},
  #     Entity.new("_:p3") => {},
  #   }
  #   assert_equal expected_rs, rs.extension
  # end
  #
  def test_refine_compare_in_range
    set = Xset.new('test', '')
    set.add_item Entity.new("_:p2")
    set.add_item Entity.new("_:p3")
    set.add_item Entity.new("_:p4")
    
    set.server = @papers_server
    rs = set.refine{|f| f.compare(relations: [SchemaRelation.new("_:publicationYear", @papers_server)], restrictions: [[">=", Xpair::Literal.new(1997.0)], ["<=", Xpair::Literal.new(2005.0)]])}
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default'),
    #   Pair.new(Entity.new("_:p3"), Entity.new("_:p3"), 'default')
    # ])
    # assert_equal expected_pairs, Set.new(rs.each_relation.first.each_pair)
    puts rs.inspect
  end

  def test_refine_compare_in_range_OR
    set = Xset.new('test', '')
    set.add_item Entity.new("_:p2")
    set.add_item Entity.new("_:p3")
    set.add_item Entity.new("_:p4")
    
    set.server = @papers_server
    rs = set.refine{|f| f.compare(relations: [SchemaRelation.new("_:publicationYear", @papers_server)], connector: "OR", restrictions: [[">", Xpair::Literal.new(1998)], ["<", Xpair::Literal.new(1998)]])}
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default'),
    #   Pair.new(Entity.new("_:p4"), Entity.new("_:p4"), 'default')
    # ])
    # assert_equal expected_pairs, Set.new(rs.each_relation.first.each_pair)
    puts rs.inspect
  end
  
  def test_compare_greater_than_equal
    set = Xset.new('test', '')
    set.add_item Entity.new("_:p2")
    set.add_item Entity.new("_:p3")
    set.add_item Entity.new("_:p4")
    
    set.server = @papers_server
    rs = set.refine{|f| f.compare(relations: [SchemaRelation.new("_:publicationYear", @papers_server)], connector: 'AND', restrictions: [[">=", Xpair::Literal.new(2000)]])}
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default'),
    #   Pair.new(Entity.new("_:p4"), Entity.new("_:p4"), 'default')
    # ])
    # assert_equal expected_pairs, Set.new(rs.each_relation.first.each_pair)
        puts rs.inspect
  end
  
  def test_compare_less_than_equal
    set = Xset.new('test', '')
    set.add_item Entity.new("_:p2")
    set.add_item Entity.new("_:p3")
    set.add_item Entity.new("_:p4")
    
    set.server = @papers_server
    rs = set.refine{|f| f.compare(relations: [SchemaRelation.new("_:publicationYear", @papers_server)], restrictions: [["<=", Xpair::Literal.new(2000)]])}
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new("_:p2"), Entity.new("_:p2"), 'default'),
    #   Pair.new(Entity.new("_:p3"), Entity.new("_:p3"), 'default')
    # ])
    # assert_equal expected_pairs, Set.new(rs.each_relation.first.each_pair)
    puts rs.inspect
  end
end