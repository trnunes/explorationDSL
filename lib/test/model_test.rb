require "test/unit"
require "rdf"
require 'linkeddata'
require './filters/dsl_prototype'

class ModelTest < Test::Unit::TestCase
  def setup
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
      graph << [RDF::URI("_:p20"),  RDF::URI("_:author"), RDF::URI("_:a3")]

      graph << [RDF::URI("_:p2"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal2")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), RDF::Literal.new("2005", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), RDF::Literal.new("2010", datatype: RDF::XSD.string)]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2000", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), RDF::Literal.new("1998", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2010", datatype: RDF::XSD.string)]     
    end

    @papers_server = RDFDataServer.new(papers_graph)
    Explorable.server = @papers_server
    
  end
  
  def test_empty
    cite = SchemaRelation.new(id: "_:cite")
    res_image = cite.restricted_image([Entity.new("_:paper2")])
    assert_equal Set.new(), Set.new(res_image.each)
    
    res_image = cite.restricted_image([Entity.new("_:p5"), Entity.new("_:p4")])
    assert_equal Set.new(), Set.new(res_image.each)
    

    res_dom = cite.restricted_domain([Entity.new("_:p6"), Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(res_dom.each)
    
    cite = SchemaRelation.new(id: "_:cite", inverse: true)
    res_image = cite.restricted_image([Entity.new("_:p6"), Entity.new("_:p7")])
    assert_equal Set.new(), Set.new(res_image.each)
    
  end
  
  def test_restricted_image
    cite = SchemaRelation.new(id: "_:cite")
    res_image = cite.restricted_image([Entity.new("_:paper1")])    
    assert_equal Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4")]), Set.new(res_image.each)
    
    sorted_res = res_image.each.sort{|i1, i2| i1.id<=>i2.id}
    assert_equal sorted_res.first.parent, Entity.new("_:paper1")
    assert_equal sorted_res[1].parent, Entity.new("_:paper1")
    assert_equal sorted_res[2].parent, Entity.new("_:paper1")
  end
  
  def test_restricted_domain
    cite = SchemaRelation.new(id: "_:cite")
    res_dom = cite.restricted_domain([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4")])
    assert_equal Set.new([Entity.new("_:paper1"), Entity.new("_:p6"), Entity.new("_:p7"), Entity.new("_:p8")]), Set.new(res_dom.each)
  end
  
  def test_inverse_restricted_image
    cite = SchemaRelation.new(id: "_:cite", inverse: true)
    res_image = cite.restricted_image([Entity.new("_:p2"), Entity.new("_:p4")])
    assert_equal Set.new([Entity.new("_:paper1"), Entity.new("_:p6")]), Set.new(res_image.each)    
  end
  
  def test_inverse_restricted_domain
    cite = SchemaRelation.new(id: "_:cite", inverse: true)
    res_dom = cite.restricted_domain([Entity.new("_:paper1")])
    assert_equal Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4")]), Set.new(res_dom.each)
    
  end

  def test_path_restricted_image
    path = PathRelation.new(relations: [SchemaRelation.new(id: "_:cite"), SchemaRelation.new(id: "_:author")])
    res_image = path.restricted_image([Entity.new("_:paper1"), Entity.new("_:p6")])
    assert_equal Set.new([Entity.new("_:a1"), Entity.new("_:a2")]), Set.new(res_image.each)
  end

  def test_path_restricted_domain
    path = PathRelation.new(relations: [SchemaRelation.new(id: "_:publishedOn"), SchemaRelation.new(id: "_:releaseYear")])
    res_image = path.restricted_domain([Literal.new("2005")])
    assert_equal Set.new([Entity.new("_:p2"), Entity.new("_:p4")]), Set.new(res_image.each)
  end
  
  def test_inverse_path_restricted_image
    expected_rs = [Entity.new("_:p7"),Entity.new("_:p8"), Entity.new("_:p9"), Entity.new("_:p10"), Entity.new("_:p6"), Entity.new("_:paper1")]
    path = PathRelation.new(relations: [SchemaRelation.new(id: "_:author", inverse: true), SchemaRelation.new(id: "_:cite", inverse: true)])
    res_image = path.restricted_image([Entity.new("_:a1")])
    assert_equal Set.new(expected_rs), Set.new(res_image.each)
  end
  
  def test_mixed_path_restricted_image    
    path = PathRelation.new(relations: [SchemaRelation.new(id: "_:cite", inverse: true), SchemaRelation.new(id: "_:author")])
    res_image = path.restricted_image([Entity.new("_:p5")])
    assert_equal Set.new(res_image.each), Set.new([Entity.new("_:a2")])
  end

  def test_mixed_path_restricted_domain
    path = PathRelation.new(relations: [SchemaRelation.new(id: "_:cite", inverse: true), SchemaRelation.new(id: "_:author")])
    res_dom = path.restricted_domain([Entity.new("_:a1")])
    assert_equal Set.new(res_dom.each), Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4")])
  end
  
  
  # def test_domain_restrict
  #   cite = SchemaRelation.new(id: "_:cite")
  #   rs = cite.domain_restrict([Entity.new("_:paper1")])
  #   # binding.pry
  #   assert_equal rs.each_domain, Set.new([Entity.new("_:paper1")])
  #   assert_equal Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4")]), Set.new(rs.each_domain.to_a.first.children)
  # end
  
  # def test_image_restrict
  #   cite = SchemaRelation.new(id: "_:cite")
  #   rs = cite.image_restrict([Entity.new("_:p2")])
  #   # binding.pry
  #   domains = rs.each_domain
  #   assert_equal Set.new(domains), Set.new([Entity.new("_:paper1"), Entity.new("_:p6")])
  #   assert_equal Set.new([Entity.new("_:p2")]), Set.new(domains.to_a[0].children)
  #   assert_equal Set.new([Entity.new("_:p2")]), Set.new(domains.to_a[1].children)
  # end
  
  def test_cursor_relation_path
    cite = PathRelation.new(relations: [SchemaRelation.new(id: "_:cite"), SchemaRelation.new(id: "_:author")])
    domain_set = Set.new([Entity.new("_:p10"), Entity.new("_:p6"), Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:p9"), Entity.new("_:paper1")])
    cursor = cite.get_cursor(2,2)
    page1 = Set.new cursor.next_page
    page2 = Set.new cursor.next_page
    page3 = Set.new cursor.next_page
    
    assert_equal page1.size, 2
    assert_equal page2.size, 2
    assert_equal page3.size, 2
    assert_true (page1 & page2 & page3).empty?
    assert_equal (page1 + page2 + page3), domain_set
    
    cursor = cite.get_cursor(2, 3)
    page1 = Set.new cursor.next_page
    page2 = Set.new cursor.next_page   
    assert_equal page1.size, 3
    assert_equal page2.size, 3
    assert_true (page1 & page2).empty?
    assert_equal (page1 + page2), domain_set
    
    cursor = cite.get_cursor(2, 4)
    page1 = Set.new cursor.next_page
    page2 = Set.new cursor.next_page
    assert_equal page1.size, 4
    assert_equal page2.size, 2
    assert_true (page1 & page2).empty?
    assert_equal (page1 + page2), domain_set
    
    
    p6 = (page1 + page2).select{|i| i.id == "_:p6"}.first
    assert_equal Set.new(p6.children), Set.new([Entity.new("_:a1"), Entity.new("_:a2")])

    paper1 = (page1 + page2).select{|i| i.id == "_:paper1"}.first
    assert_equal Set.new(paper1.children), Set.new([Entity.new("_:a1"), Entity.new("_:a2")])
    
    
  end

  def test_paths
    r = ComputedRelation.new("root")
    r.add_path [Entity.new("i1"), Entity.new("i1.1")]
    r.add_path [Entity.new("i2"), Entity.new("i2.1")]
    
    paths = r.paths

    assert_equal Set.new(paths), Set.new([[Entity.new("root"), Entity.new("i1"), Entity.new("i1.1")],[Entity.new("root"), Entity.new("i2"), Entity.new("i2.1")]])
  end
  
  def test_cursor_restricted_relation_on_image
    cursor = SchemaRelation.new(id: "_:cite").restricted_domain([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p5")])

    cursor.paginate(4)
    page1 = Set.new(cursor.next_page)
    page2 = Set.new(cursor.next_page)
    assert_equal page1.size, 4
    assert_equal page2.size, 2
    assert_true (page1 & page2).empty?
    assert_equal (page1 + page2), Set.new([Entity.new("_:p6"), Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:paper1"), Entity.new("_:p10"), Entity.new("_:p9")])
    
    paper1 = (page1 + page2).select{|i| i.id == "_:paper1"}.first
    p6 = (page1 + page2).select{|i| i.id == "_:p6"}.first
    
    assert_equal Set.new(paper1.children), Set.new([Entity.new("_:p2"), Entity.new("_:p3")])
    assert_equal Set.new(p6.children), Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p5")])
    
    cursor.paginate(3)
    
    page1 = Set.new(cursor.next_page)
    page2 = Set.new(cursor.next_page)
    assert_equal page1.size, 3
    assert_equal page2.size, 3
    assert_true (page1 & page2).empty?
    assert_equal (page1 + page2), Set.new([Entity.new("_:p6"), Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:paper1"), Entity.new("_:p10"), Entity.new("_:p9")])
    
  end
  
  def test_cursor_restricted_relation_on_domain
    cursor = SchemaRelation.new(id: "_:cite").restricted_image([Entity.new("_:paper1"), Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p6"), Entity.new("_:p7")])
    cursor.paginate(2)

    page1 = Set.new(cursor.next_page)
    page2 = Set.new(cursor.next_page)
    assert_equal page1.size, 2
    assert_equal page2.size, 2
    assert_true (page1 & page2).empty?
    assert_equal (page1 + page2), Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4"), Entity.new("_:p5")])
    
    p4 = (page1 + page2).select{|i| i.id == "_:p4"}.first
    p5 = (page1 + page2).select{|i| i.id == "_:p5"}.first
    
    assert_equal p4.parent, Entity.new("_:paper1")
    assert_equal p5.parent, Entity.new("_:p6")
    
  end
  
  def test_cursor_restricted_relation_path_on_image
    cursor = PathRelation.new(relations: [SchemaRelation.new(id: "_:cite"), SchemaRelation.new(id: "_:author")]).restricted_domain([Entity.new("_:a1")])
    domain_set = Set.new([Entity.new("_:paper1"), Entity.new("_:p6"), Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:p9"), Entity.new("_:p10")])
    cursor.paginate(2)

    page1 = Set.new(cursor.next_page)
    page2 = Set.new(cursor.next_page)
    page3 = Set.new(cursor.next_page)
    assert_equal page1.size, 2
    assert_equal page2.size, 2
    assert_equal page3.size, 2
    assert_true (page1 & page2 & page3).empty?
    assert_equal (page1 + page2 + page3), domain_set
    
    paper1 = (page1 + page2 + page3).select{|i| i.id == "_:paper1"}.first
    p6 = (page1 + page2 + page3).select{|i| i.id == "_:p6"}.first
    p5 = (page1 + page2 + page3).select{|i| i.id == "_:p7"}.first
    
    assert_equal Set.new(paper1.children), Set.new([Entity.new("_:a1")])
    assert_equal Set.new(p6.children), Set.new([Entity.new("_:a1")])    
    assert_equal Set.new(p5.children), Set.new([Entity.new("_:a1")])    
    
  end

  def test_cursor_restricted_relation_path_on_domain
    cursor = PathRelation.new(relations: [SchemaRelation.new(id: "_:cite"), SchemaRelation.new(id: "_:publishedOn")]).restricted_image([Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:p9")])
    domain_set = Set.new([Entity.new("_:p7"), Entity.new("_:p8")])
    cursor.paginate(1)
    page1 = Set.new(cursor.next_page)
    assert_equal page1.size, 1
    
    assert_equal Set.new(page1), Set.new([Entity.new("_:journal2")])    

    
  end
  
  def test_cursor_for_level_shema_relation
    cite = SchemaRelation.new(id: "_:cite")
    cursor = cite.get_cursor(2, 3)
    page1 = Set.new(cursor.next_page)
    page2 = Set.new(cursor.next_page)
    
    assert_equal page1.size, 3
    assert_equal page2.size, 3
    assert_equal Set.new([Entity.new("_:paper1"), Entity.new("_:p6"), Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:p9"), Entity.new("_:p10")]), (page1 + page2)
    
    cursor = cite.get_cursor(3, 3)
    page1 = Set.new(cursor.next_page)
    page2 = Set.new(cursor.next_page)
    
    assert_equal page1.size, 3
    assert_equal page2.size, 1
    assert_equal Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4"), Entity.new("_:p5")]), (page1 + page2)
    
  end
  
  def test_cursor_computed_relation
    cr = ComputedRelation.new("myComputedRelation")

    i11 = Entity.new("i1.1")
    i111 = Entity.new("i1.1.1")
    i112 = Entity.new("i1.1.2")
    i113 = Entity.new("i1.1.3")
    i114 = Entity.new("i1.1.4")
    
    i12 = Entity.new("i1.2")
    i121 = Entity.new("i1.2.1")
    i122 = Entity.new("i1.2.2")
    i123 = Entity.new("i1.2.3")
    i124 = Entity.new("i1.2.4")
    
    i11.children = [i111, i112, i113, i114]
    i12.children = [i121, i122, i123, i124]
    
    cr.root.children = [i11, i12]
    level2_cursor = cr.get_cursor(2,1)
    
    assert_equal Set.new([i11]), Set.new(level2_cursor.next_page)
    assert_equal Set.new([i12]), Set.new(level2_cursor.next_page)
    
    level2_cursor = cr.get_cursor(3,4)
    
    assert_equal Set.new([i111, i112, i113, i114]), Set.new(level2_cursor.next_page)
    assert_equal Set.new([i121, i122, i123, i124]), Set.new(level2_cursor.next_page)
    
  end
  
end