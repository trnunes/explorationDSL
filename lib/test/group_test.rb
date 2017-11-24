# require './test/xpair_unit_test'
require "test/unit"
require "rdf"
require 'linkeddata'
require './filters/dsl_prototype'

class GroupTest < Test::Unit::TestCase

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
    Explorable.server = @papers_server
  end
  
  def test_group_by
    s = Xset.new{entities "_:paper1", "_:p2", "_:p3"}
    author_relation = Xplain::SchemaRelation.new("_:author", inverse: true)
    # s.server = @server
    
    rs = s.group do
      by_image relation("_:author")
    end

    assert_equal Set.new(rs.each), Set.new([Entity.new("_:a1"), Entity.new("_:a2")])
    assert_equal Set.new(rs.leaves), Set.new([Entity.new("_:paper1"), Entity.new("_:p2"), Entity.new("_:p3")])
    a1 = rs.each.select{|a| a.id == "_:a1"}.first
    a2 = rs.each.select{|a| a.id == "_:a2"}.first
    assert_equal [author_relation], a1.children.map{|c| c.item}
    assert_equal [author_relation], a2.children.map{|c| c.item}
    author_relation_a1 = a1.children.first
    author_relation_a2 = a2.children.first

    
    assert_equal Set.new([Entity.new("_:paper1"), Entity.new("_:p2")]), Set.new(author_relation_a1.children)

    assert_equal Set.new([Entity.new("_:paper1"), Entity.new("_:p3")]), Set.new(author_relation_a1.children)
    
  end
  
  def test_nested_group_by
    s = Xset.new{entities "_:paper1", "_:p2", "_:p3"}
    
    # s.server = @server
    
    rs = s.group do
      by_image relation("_:author")
    end.group do 
      by_image relation("_:publishedOn")
    end
        
    assert_equal Set.new(rs.root.children), Set.new([Entity.new("_:a1"), Entity.new("_:a2")])
    assert_equal Set.new(rs.leaves), Set.new([Entity.new("_:p2"), Entity.new("_:p3")])
    a1 = rs.root.children.select{|a| a.id == "_:a1"}.first
    a2 = rs.root.children.select{|a| a.id == "_:a2"}.first
    

    assert_equal Set.new([Entity.new("_:journal1")]), Set.new(a1.children)

    assert_equal Set.new([Entity.new("_:journal2")]), Set.new(a2.children)
    
    j1 = a1.children.select{|j| j.id == "_:journal1"}.first
    j2 = a2.children.select{|j| j.id == "_:journal2"}.first
    
    assert_equal Set.new([Entity.new("_:p2")]), Set.new(j1.children)
    assert_equal Set.new([Entity.new("_:p3")]), Set.new(j2.children)
  end
  
  def test_group_by_computed_relation
    s = Xset.new{entities "_:p1", "_:p2", "_:p3", "_:p4"}
    r = ComputedRelation.new("root")
    e1 = Entity.new("_:p1")
    e1.children = Entity.new("_:i1")
    e2 = Entity.new("_:p2")
    e2.children = Entity.new("_:i2")
    e3 = Entity.new("_:p3")
    e3.children = Entity.new("_:i1")
    e4 = Entity.new("_:p4")
    e4.children = Entity.new("_:i2")   
    
    r.root.set_children [e1, e2, e3, e4]
    
    rs = s.group{by_image r}
    assert_equal Set.new(rs.root.children), Set.new([Entity.new("_i1"), Entity.new("_:i2")])
    assert_equal Set.new(rs.leaves), Set.new([Entity.new("_:p1"), Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4")])
    
    
    i1 = rs.root.children.select{|a| a.id == "_:i1"}.first
    i2 = rs.root.children.select{|a| a.id == "_:i2"}.first
    assert_equal Set.new([Entity.new("_:p1"), Entity.new("_:p2")]), Set.new(i1.children)
    assert_equal Set.new([Entity.new("_:p3"), Entity.new("_:p4")]), Set.new(i2.children)
  end
  # def test_group_by_computed_relation
  #   test_set = Xset.new('test', '')
  #   test_set.add_pair(Entity.new("_:p1"), Entity.new("_:p1"))
  #   test_set.add_pair(Entity.new("_:p2"), Entity.new("_:p2"))
  #   test_set.add_pair(Entity.new("_:p3"), Entity.new("_:p3"))
  #
  #
  #   test_set.server = @server
  #
  #   pivot_rs = test_set.pivot_forward(relations: [SchemaRelation.new("_:r1", @papers_server)])
  #
  #   rs = test_set.group{|gf| gf.by_relation(relations: [pivot_rs])}
  #
  #   expected_set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:o1") => Xsubset.new("key"){|s|
  #         s.extension = {
  #           Entity.new("_:p1")=>{}
  #         }
  #       },
  #       Entity.new("_:o2") => Xsubset.new("key"){|s|
  #         s.extension = {
  #           Entity.new("_:p1")=>{},
  #           Entity.new("_:p2")=>{}
  #         }
  #       },
  #       Entity.new("_:o3") => Xsubset.new("key"){|s|
  #         s.extension = {
  #           Entity.new("_:p3")=>{}
  #         }
  #       },
  #     }
  #   end
  #   assert_equal expected_set.extension[Entity.new("_:o1")].extension, rs.extension[Entity.new("_:o1")].extension
  #   assert_equal expected_set.extension[Entity.new("_:o2")].extension, rs.extension[Entity.new("_:o2")].extension
  #   assert_equal expected_set.extension[Entity.new("_:o3")].extension, rs.extension[Entity.new("_:o3")].extension
  #
  # end
  #
  #
  # def test_group_by_keep_structure
  #   test_set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #   end
  #
  #   test_set.server = @server
  #
  #   rs1 = test_set.group{|gf| gf.by_relation(relations: [Relation.new("_:r1")])}
  #
  #   expected_set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:o1") => Xsubset.new("key"){|s|
  #         s.extension = {
  #           Entity.new("_:p1")=>{}
  #         }
  #       },
  #       Entity.new("_:o2") => Xsubset.new("key"){|s|
  #         s.extension = {
  #           Entity.new("_:p1")=>{},
  #           Entity.new("_:p2")=>{}
  #         }
  #       },
  #       Entity.new("_:o3") => Xsubset.new("key"){|s|
  #         s.extension = {
  #           Entity.new("_:p3")=>{}
  #         }
  #       },
  #     }
  #   end
  #   expected_set.server = @server
  #
  #   # assert_equal expected_set.extension, rs1.extension
  #
  #   rs = rs1.group{|gf| gf.by_relation(relations: [Relation.new("_:year")])}
  #
  #   key1 = Xsubset.new("key"){|s|
  #     s.extension = {
  #       Entity.new("_:p1")=>{}
  #     }
  #   }
  #   key2 = Xsubset.new("key"){|s|
  #     s.extension = {
  #       Entity.new("_:p1")=>{},
  #       Entity.new("_:p2")=>{}
  #     }
  #   }
  #   key3 =  Xsubset.new("key"){|s|
  #     s.extension = {
  #       Entity.new("_:p3")=>{}
  #     }
  #   }
  #   group1 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p1")=>{}}}
  #   group2 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p1")=>{}, Entity.new("_:p2")=>{}}}
  #   group3 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p3")=>{}}}
  #
  #   group4 = Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2005)=>group1}}
  #   group5 = Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2005)=>group2}}
  #   group6 = Xsubset.new("key"){|s| s.extension = {Xpair::Literal.new(2010)=>group3}}
  #
  #   expected_extension = {
  #     Xsubset.new("key"){|s|
  #       s.extension = {
  #         Entity.new("_:p1")=>{}
  #       }
  #     } => group4,
  #     Xsubset.new("key"){|s|
  #       s.extension = {
  #         Entity.new("_:p1")=>{},
  #         Entity.new("_:p2")=>{}
  #       }
  #     } => group5,
  #     Xsubset.new("key"){|s|
  #       s.extension = {
  #         Entity.new("_:p3")=>{}
  #       }
  #     }=> group6
  #   }
  #
  #
  #   rs.extension.each do |key, values|
  #
  #
  #     HashHelper.print_hash key.extension
  #
  #
  #     values.extension.each do |key, values|
  #
  #
  #       HashHelper.print_hash values.extension
  #     end
  #
  #
  #   end
  #
  #   rs.extension.keys.each do |key|
  #
  #     HashHelper.print_hash key.extension
  #   end
  #
  #   expected_extension.keys.each do |key|
  #
  #     HashHelper.print_hash key.extension
  #   end
  #
  #   assert_equal Set.new(rs.extension.keys), Set.new(expected_extension.keys)
  #   assert_equal rs.extension[key1], expected_extension[key1]
  #
  #   assert_equal expected_extension, rs.extension
  # end
  #
  # def test_group_by_domain
  #   test_set = Xset.new do |s|
  #     s << Entity.new("_:p1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #   end
  #
  #   test_set.server = @server
  #   test_set.id = "s1"
  #   pivot_rs = test_set.pivot_forward(relations: [Relation.new("_:r1")])
  #   group_rs = pivot_rs.group{|g| g.by_domain(relations: [test_set])}
  #
  #   expected_extension = {
  #     Entity.new("_:p1")=>Xsubset.new("key"){|s| s.extension = {Entity.new("_:o1")=>{},Entity.new("_:o2")=>{}}},
  #     Entity.new("_:p2")=>Xsubset.new("key"){|s| s.extension = {Entity.new("_:o2")=>{}}},
  #     Entity.new("_:p3")=>Xsubset.new("key"){|s| s.extension = {Entity.new("_:o3")=>{}}}
  #   }
  #
  #   assert_equal expected_extension[Entity.new("_:p1")].extension, group_rs.extension[Entity.new("_:p1")].extension
  #   assert_equal expected_extension[Entity.new("_:p2")].extension, group_rs.extension[Entity.new("_:p2")].extension
  #   assert_equal expected_extension[Entity.new("_:p3")].extension, group_rs.extension[Entity.new("_:p3")].extension
  #
  # end
  #
  # def test_group_by_relation
  #   test_set = Xset.new do |s|
  #     s << Entity.new("_:paper1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #     s << Entity.new("_:p4")
  #     s << Entity.new("_:p5")
  #     s << Entity.new("_:p6")
  #     s << Entity.new("_:p7")
  #     s << Entity.new("_:p8")
  #     s << Entity.new("_:p9")
  #     s << Entity.new("_:p10")
  #   end
  #   test_set.server = @papers_server
  #   test_set.id = "s1"
  #   pivot_rs = test_set.pivot_forward(relations: [Relation.new("_:author")])
  #   pivot_rs.id = "spivot"
  #   group_rs = test_set.group{|g| g.by_relation(relations: [pivot_rs])}
  #   assert_equal 2, group_rs.each_image.size
  # end
  #
  # def test_group_by_group
  #   test_set = Xset.new do |s|
  #     s << Entity.new("_:paper1")
  #     s << Entity.new("_:p2")
  #     s << Entity.new("_:p3")
  #     s << Entity.new("_:p4")
  #     s << Entity.new("_:p5")
  #     s << Entity.new("_:p6")
  #     s << Entity.new("_:p7")
  #     s << Entity.new("_:p8")
  #     s << Entity.new("_:p9")
  #     s << Entity.new("_:p10")
  #   end
  #   test_set.server = @papers_server
  #   test_set.id = "s1"
  #   pivot_rs = test_set.group{|g| g.by_relation(relations: [Relation.new("_:author")])}
  #   pivot_rs.id = "spivot"
  #   group_rs = pivot_rs.group{|g| g.by_relation(relations: [Relation.new("_:cite")])}
  #
  #   assert_equal 2, group_rs.each_image.size
  # end
  
end