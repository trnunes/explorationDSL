require './test/xplain_unit_test'

class ModelTest < XplainUnitTest
  
  def test_empty
    cite = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite")
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:paper2")])
    assert_equal Set.new(), Set.new(actual_image.to_a)
    
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p4")])
    assert_equal Set.new(), Set.new(actual_image.to_a)
    

    res_dom = cite.restricted_domain(create_nodes [Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(res_dom.to_a)
    
    cite = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite", inverse: true)
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(actual_image.to_a)
    
  end
  
  def test_restricted_image
    cite = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite")
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:paper1")])
    expected_image = Set.new(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
    assert_equal expected_image, Set.new(actual_image.to_a)

    assert_equal actual_image[0].parent.item, Xplain::Entity.new("_:paper1")
    assert_equal actual_image[1].parent.item, Xplain::Entity.new("_:paper1")
    assert_equal actual_image[2].parent.item, Xplain::Entity.new("_:paper1")
  end
  
  def test_restricted_domain
    cite = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite")
    res_dom = cite.restricted_domain(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
    expected_domain = Set.new(create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8")])
    assert_equal expected_domain, Set.new(res_dom.to_a)
  end
  
  def test_inverse_restricted_image
    cite = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite", inverse: true)
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")])
    expected_image = Set.new(create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")])
    assert_equal expected_image, Set.new(actual_image.to_a)
  end
  
  def test_inverse_restricted_domain
    cite = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite", inverse: true)
    res_dom = cite.restricted_domain(create_nodes [Xplain::Entity.new("_:paper1")])
    expected_domain = Set.new(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
    assert_equal expected_domain, Set.new(res_dom.to_a)
    
  end

  def test_path_restricted_image
    path = Xplain::PathRelation.new(server: @papers_server, relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite"), Xplain::SchemaRelation.new(server: @papers_server, id: "_:author")])
    actual_image = path.restricted_image(create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6")])
    expected_image = Set.new(create_nodes [Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")])
    assert_equal expected_image, Set.new(actual_image.to_a)
  end

  def test_path_restricted_domain
    path = Xplain::PathRelation.new(server: @papers_server, relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:publishedOn"), Xplain::SchemaRelation.new(server: @papers_server, id: "_:releaseYear")])
    actual_image = path.restricted_domain(create_nodes [Xplain::Literal.new("2005", RDF::XSD.string)])
    expected_image = Set.new(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")])
    assert_equal expected_image, Set.new(actual_image.to_a)
  end
  
  def test_inverse_path_restricted_image
    expected_rs = create_nodes [Xplain::Entity.new("_:p7"),Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")]
    path = Xplain::PathRelation.new(server: @papers_server, relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:author", inverse: true), Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite", inverse: true)])
    actual_image = path.restricted_image(create_nodes [Xplain::Entity.new("_:a1")])
    assert_equal Set.new(expected_rs), Set.new(actual_image.to_a)
  end
  
  def test_mixed_path_restricted_image    
    path = Xplain::PathRelation.new(server: @papers_server, relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite", inverse: true), Xplain::SchemaRelation.new(server: @papers_server, id: "_:author")])
    actual_image = path.restricted_image(create_nodes [Xplain::Entity.new("_:p5")])
    assert_equal Set.new(actual_image.to_a), Set.new(create_nodes [Xplain::Entity.new("_:a2")])
  end

  def test_mixed_path_restricted_domain
    path = Xplain::PathRelation.new(server: @papers_server, relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite", inverse: true), Xplain::SchemaRelation.new(server: @papers_server, id: "_:author")])
    res_dom = path.restricted_domain(create_nodes [Xplain::Entity.new("_:a1")])
    assert_equal Set.new(res_dom.to_a), Set.new(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
  end
  ############# TEST COMPUTED RELATION ######################

  def test_empty_computed_relation

    cite = Xplain::ComputedRelation.new()
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:paper2")])
    assert_equal Set.new(), Set.new(actual_image.to_a)
    
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p4")])
    assert_equal Set.new(), Set.new(actual_image.to_a)
    

    res_dom = cite.restricted_domain(create_nodes [Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(res_dom.to_a)
    
    cite = Xplain::ComputedRelation.new(inverse: true)
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(actual_image.to_a)
    
  end
  
  def test_restricted_image_computed_relation
    paper1 = Node.new(Xplain::Entity.new("_:paper1"))
    p2 = Node.new(Xplain::Entity.new("_:p2"))
    paper1.children = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    p2.children = create_nodes [Xplain::Entity.new("_:p5")]

    cite = Xplain::ComputedRelation.new(domain: [paper1, p2])
    actual_image = cite.restricted_image(create_nodes [Xplain::Entity.new("_:paper1")])
    expected_image = Set.new(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
    assert_equal expected_image, Set.new(actual_image.to_a)

    assert_equal actual_image[0].parent.item, Xplain::Entity.new("_:paper1")
    assert_equal actual_image[1].parent.item, Xplain::Entity.new("_:paper1")
    assert_equal actual_image[2].parent.item, Xplain::Entity.new("_:paper1")
  end
  
  def test_restricted_domain_computed_relation
    paper1 = Node.new(Xplain::Entity.new("_:paper1"))
    p2 = Node.new(Xplain::Entity.new("_:p2"))
    paper1.children = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    p2.children = create_nodes [Xplain::Entity.new("_:p5")]
    
    cite = Xplain::ComputedRelation.new(domain: [paper1, p2])
    res_dom = cite.restricted_domain(create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
    expected_domain = Set.new(create_nodes [Xplain::Entity.new("_:paper1")])
    assert_equal expected_domain, Set.new(res_dom.to_a)
  end  
  
  def test_group_by_computed_relation
    paper1 = Node.new(Xplain::Entity.new("_:paper1"))
    p2 = Node.new(Xplain::Entity.new("_:p2"))
    paper1.children = create_nodes [Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    p2.children = create_nodes [Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p5")]
    
    expected_groups = create_nodes [Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    p3_children = [p2, paper1]
    p4_children = [paper1]
    p5_children = [p2]
    
    actual_groups = Xplain::ComputedRelation.new(domain: [paper1, p2]).group_by_image([p2, paper1])
    assert_equal expected_groups, actual_groups.to_a
    
    actual_p3_children = actual_groups.select{|n| n.item.id == "_:p3"}[0].children
    actual_p4_children = actual_groups.select{|n| n.item.id == "_:p4"}[0].children
    actual_p5_children = actual_groups.select{|n| n.item.id == "_:p5"}[0].children
    
    assert_equal Set.new(p3_children), Set.new(actual_p3_children)
    assert_equal Set.new(p4_children), Set.new(actual_p4_children)
    assert_equal Set.new(p5_children), Set.new(actual_p5_children)
    
  end
  # def test_cursor_relation_path
  #   cite = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite"), Xplain::SchemaRelation.new(server: @papers_server, id: "_:author")])
  #   domain_set = Set.new([Xplain::Entity.new("_:p10"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:paper1")])
  #   cursor = cite.get_cursor(2,2)
  #   page1 = Set.new cursor.next_page
  #   page2 = Set.new cursor.next_page
  #   page3 = Set.new cursor.next_page
  #
  #   assert_equal page1.size, 2
  #   assert_equal page2.size, 2
  #   assert_equal page3.size, 2
  #   assert_true (page1 & page2 & page3).empty?
  #   assert_equal (page1 + page2 + page3), domain_set
  #
  #   cursor = cite.get_cursor(2, 3)
  #   page1 = Set.new cursor.next_page
  #   page2 = Set.new cursor.next_page
  #   assert_equal page1.size, 3
  #   assert_equal page2.size, 3
  #   assert_true (page1 & page2).empty?
  #   assert_equal (page1 + page2), domain_set
  #
  #   cursor = cite.get_cursor(2, 4)
  #   page1 = Set.new cursor.next_page
  #   page2 = Set.new cursor.next_page
  #   assert_equal page1.size, 4
  #   assert_equal page2.size, 2
  #   assert_true (page1 & page2).empty?
  #   assert_equal (page1 + page2), domain_set
  #
  #
  #   p6 = (page1 + page2).select{|i| i.id == "_:p6"}.first
  #   assert_equal Set.new(p6.children), Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")])
  #
  #   paper1 = (page1 + page2).select{|i| i.id == "_:paper1"}.first
  #   assert_equal Set.new(paper1.children), Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")])
  #
  #
  # end
  #
  # def test_paths
  #   r = Xplain::PathRelation.new("root")
  #   r.add_path [Xplain::Entity.new("i1"), Xplain::Entity.new("i1.1")]
  #   r.add_path [Xplain::Entity.new("i2"), Xplain::Entity.new("i2.1")]
  #
  #   paths = r.paths
  #
  #   assert_equal Set.new(paths), Set.new([[Xplain::Entity.new("root"), Xplain::Entity.new("i1"), Xplain::Entity.new("i1.1")],[Xplain::Entity.new("root"), Xplain::Entity.new("i2"), Xplain::Entity.new("i2.1")]])
  # end
  #
  # def test_cursor_restricted_relation_on_image
  #   cursor = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite").restricted_domain([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p5")])
  #
  #   cursor.paginate(4)
  #   page1 = Set.new(cursor.next_page)
  #   page2 = Set.new(cursor.next_page)
  #   assert_equal page1.size, 4
  #   assert_equal page2.size, 2
  #   assert_true (page1 & page2).empty?
  #   assert_equal (page1 + page2), Set.new([Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p10"), Xplain::Entity.new("_:p9")])
  #
  #   paper1 = (page1 + page2).select{|i| i.id == "_:paper1"}.first
  #   p6 = (page1 + page2).select{|i| i.id == "_:p6"}.first
  #
  #   assert_equal Set.new(paper1.children), Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])
  #   assert_equal Set.new(p6.children), Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p5")])
  #
  #   cursor.paginate(3)
  #
  #   page1 = Set.new(cursor.next_page)
  #   page2 = Set.new(cursor.next_page)
  #   assert_equal page1.size, 3
  #   assert_equal page2.size, 3
  #   assert_true (page1 & page2).empty?
  #   assert_equal (page1 + page2), Set.new([Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p10"), Xplain::Entity.new("_:p9")])
  #
  # end
  #
  # def test_cursor_restricted_relation_on_domain
  #   cursor = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite").restricted_image([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")])
  #   cursor.paginate(2)
  #
  #   page1 = Set.new(cursor.next_page)
  #   page2 = Set.new(cursor.next_page)
  #   assert_equal page1.size, 2
  #   assert_equal page2.size, 2
  #   assert_true (page1 & page2).empty?
  #   assert_equal (page1 + page2), Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")])
  #
  #   p4 = (page1 + page2).select{|i| i.id == "_:p4"}.first
  #   p5 = (page1 + page2).select{|i| i.id == "_:p5"}.first
  #
  #   assert_equal p4.parent, Xplain::Entity.new("_:paper1")
  #   assert_equal p5.parent, Xplain::Entity.new("_:p6")
  #
  # end
  #
  # def test_cursor_restricted_relation_path_on_image
  #   cursor = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite"), Xplain::SchemaRelation.new(server: @papers_server, id: "_:author")]).restricted_domain([Xplain::Entity.new("_:a1")])
  #   domain_set = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")])
  #   cursor.paginate(2)
  #
  #   page1 = Set.new(cursor.next_page)
  #   page2 = Set.new(cursor.next_page)
  #   page3 = Set.new(cursor.next_page)
  #   assert_equal page1.size, 2
  #   assert_equal page2.size, 2
  #   assert_equal page3.size, 2
  #   assert_true (page1 & page2 & page3).empty?
  #   assert_equal (page1 + page2 + page3), domain_set
  #
  #   paper1 = (page1 + page2 + page3).select{|i| i.id == "_:paper1"}.first
  #   p6 = (page1 + page2 + page3).select{|i| i.id == "_:p6"}.first
  #   p5 = (page1 + page2 + page3).select{|i| i.id == "_:p7"}.first
  #
  #   assert_equal Set.new(paper1.children), Set.new([Xplain::Entity.new("_:a1")])
  #   assert_equal Set.new(p6.children), Set.new([Xplain::Entity.new("_:a1")])
  #   assert_equal Set.new(p5.children), Set.new([Xplain::Entity.new("_:a1")])
  #
  # end
  #
  # def test_cursor_restricted_relation_path_on_domain
  #   cursor = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite"), Xplain::SchemaRelation.new(server: @papers_server, id: "_:publishedOn")]).restricted_image([Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9")])
  #   domain_set = Set.new([Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8")])
  #   cursor.paginate(1)
  #   page1 = Set.new(cursor.next_page)
  #   assert_equal page1.size, 1
  #
  #   assert_equal Set.new(page1), Set.new([Xplain::Entity.new("_:journal2")])
  #
  #
  # end
  #
  # def test_cursor_for_level_shema_relation
  #   cite = Xplain::SchemaRelation.new(server: @papers_server, id: "_:cite")
  #   cursor = cite.get_cursor(2, 3)
  #   page1 = Set.new(cursor.next_page)
  #   page2 = Set.new(cursor.next_page)
  #
  #   assert_equal page1.size, 3
  #   assert_equal page2.size, 3
  #   assert_equal Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")]), (page1 + page2)
  #
  #   cursor = cite.get_cursor(3, 3)
  #   page1 = Set.new(cursor.next_page)
  #   page2 = Set.new(cursor.next_page)
  #
  #   assert_equal page1.size, 3
  #   assert_equal page2.size, 1
  #   assert_equal Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]), (page1 + page2)
  #
  # end
  #
  # def test_cursor_computed_relation
  #   cr = Xplain::PathRelation.new("myXplain::PathRelation")
  #
  #   i11 = Xplain::Entity.new("i1.1")
  #   i111 = Xplain::Entity.new("i1.1.1")
  #   i112 = Xplain::Entity.new("i1.1.2")
  #   i113 = Xplain::Entity.new("i1.1.3")
  #   i114 = Xplain::Entity.new("i1.1.4")
  #
  #   i12 = Xplain::Entity.new("i1.2")
  #   i121 = Xplain::Entity.new("i1.2.1")
  #   i122 = Xplain::Entity.new("i1.2.2")
  #   i123 = Xplain::Entity.new("i1.2.3")
  #   i124 = Xplain::Entity.new("i1.2.4")
  #
  #   i11.children = [i111, i112, i113, i114]
  #   i12.children = [i121, i122, i123, i124]
  #
  #   cr.root.children = [i11, i12]
  #   level2_cursor = cr.get_cursor(2,1)
  #
  #   assert_equal Set.new([i11]), Set.new(level2_cursor.next_page)
  #   assert_equal Set.new([i12]), Set.new(level2_cursor.next_page)
  #
  #   level2_cursor = cr.get_cursor(3,4)
  #
  #   assert_equal Set.new([i111, i112, i113, i114]), Set.new(level2_cursor.next_page)
  #   assert_equal Set.new([i121, i122, i123, i124]), Set.new(level2_cursor.next_page)
  #
  # end
  
end