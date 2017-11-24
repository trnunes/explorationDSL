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
    set = Xset.new('test', '')
    set.map{|mf|mf.count}.empty?
    
    set.map{|mf| mf.avg()}.empty?
  end
  
  # def test_map_level3
  #   subset1 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p3") => {},Entity.new("_:p4") => {}}}
  #   subset2 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p2") => {}}}
  #   subset3 = Xsubset.new("key"){|s| s.extension = {Relation.new("_:cite") => subset1}}
  #   subset4 = Xsubset.new("key"){|s| s.extension = {Relation.new("_:cite") => subset2}}
  #   set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:paper1")=>subset3,
  #       Entity.new("_:p5")=>subset4
  #     }
  #
  #   end
  #   set.server = @papers_server
  #   h1 = {
  #     subset1=>{Xpair::Literal.new(2) => {}},
  #     subset2=>{Xpair::Literal.new(1) => {}}
  #   }
  #
  #
  #   assert_equal h1, set.map{|mf|mf.count}.extension
  #
  # end
  
  def test_map_count
    set = Xset.new('test', '')
    set.add_item Entity.new('_:p2')
    set.add_item Entity.new('_:p3')
    set.add_item Entity.new('_:p4')
    set.add_item Entity.new('_:p5')
    set.add_item Entity.new('_:p6')
    
    expected_pairs = Set.new([Xpair::Literal.new(5)])
    
    assert_equal expected_pairs, Set.new(set.map{|mf| mf.count}.each_item)
  end
  
  def test_map_count_grouped_set
    set = Xset.new('test', '')
    p2 = Entity.new('_:p2')
    p2.index = Indexing::Entry.new('root')
    p2.index.children << Indexing::Entry.new(Entity.new('_:p1'))    
    p3 = Entity.new('_:p3')
    p3.index = Indexing::Entry.new('root')
    p3.index.children << Indexing::Entry.new(Entity.new('_:p1'))
    p4 = Entity.new('_:p4')
    p4.index = Indexing::Entry.new('root')
    p4.index.children << Indexing::Entry.new(Entity.new('_:p2'))
    p5 = Entity.new('_:p5')
    p5.index = Indexing::Entry.new('root')
    p5.index.children << Indexing::Entry.new(Entity.new('_:p2'))
    p6 = Entity.new('_:p6')
    p6.index = Indexing::Entry.new('root')
    p6.index.children << Indexing::Entry.new(Entity.new('_:p2'))
    
    set.add_item p2
    set.add_item p3
    set.add_item p4
    set.add_item p5
    set.add_item p6
    
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new('_:p1'), Xpair::Literal.new(2), "_:p1"),
    #   Pair.new(Entity.new('_:p2'), Xpair::Literal.new(3), "_:p2")
    # ])
    rs = set.map{|mf| mf.count(replace: "image")}
    # assert_equal expected_pairs, Set.new(rs.each_relation[0].each_pair + rs.each_relation[1].each_pair)
    puts "test_map_count_grouped_set"
    puts rs.inspect
    
  end
  
  def test_average
    
    set = Xset.new('test', '')
    l1 = Xpair::Literal.new(1)
    l1.index = Indexing::Entry.new('root')
    l1.index.children << Indexing::Entry.new(Entity.new('_:p1'))    
    l2 = Xpair::Literal.new(2)
    l2.index = Indexing::Entry.new('root')
    l2.index.children << Indexing::Entry.new(Entity.new('_:p1'))    
    l3 = Xpair::Literal.new(3)
    l3.index = Indexing::Entry.new('root')
    l3.index.children << Indexing::Entry.new(Entity.new('_:p1'))    
    l4 = Xpair::Literal.new(4)
    l4.index = Indexing::Entry.new('root')
    l4.index.children << Indexing::Entry.new(Entity.new('_:p1'))
    
    set.add_item l1
    set.add_item l2
    set.add_item l3
    set.add_item l4
    
    rs = set.map{|mf| mf.avg}
    # expected_pairs = Set.new([Pair.new(Xpair::Literal.new(2.5), Xpair::Literal.new(2.5))])

    # assert_equal expected_pairs, Set.new(rs.each_relation.first.each_pair)
    puts "test_average"
    puts rs.inspect
  end
  
  def test_average_grouped_set
    set = Xset.new('test', '')
    
    l3 = Xpair::Literal.new(3)
    l3.index = Indexing::Entry.new('root')
    l3.index.children << Indexing::Entry.new(Entity.new('_:p1'))
        
    l2 = Xpair::Literal.new(2)
    l2.index = Indexing::Entry.new('root')
    l2.index.children << Indexing::Entry.new(Entity.new('_:p1'))    

    l21 = Xpair::Literal.new(2)
    l21.index = Indexing::Entry.new('root')
    l21.index.children << Indexing::Entry.new(Entity.new('_:p2'))    
    
    l22 = Xpair::Literal.new(3)
    l22.index = Indexing::Entry.new('root')
    l22.index.children << Indexing::Entry.new(Entity.new('_:p2'))    
    
    l5 = Xpair::Literal.new(4)
    l5.index = Indexing::Entry.new('root')
    l5.index.children << Indexing::Entry.new(Entity.new('_:p2'))
    
    set.add_item l2
    set.add_item l3
    set.add_item l21
    set.add_item l22
    set.add_item l5
    
    # expected_pairs = Set.new([
    #   Pair.new(Entity.new('_:p1'), Xpair::Literal.new(2.5), "_:p1"),
    #   Pair.new(Entity.new('_:p2'), Xpair::Literal.new(3.0), "_:p2")
    # ])
    rs = set.map{|mf| mf.avg(replace: "image")}

    # assert_equal expected_pairs, Set.new(rs.each_relation[0].each_pair + rs.each_relation[1].each_pair)
    puts "test_average_grouped_set"
    puts rs.inspect

  end
  
  def test_user_defined
    options = {}
    options[:initializer] = "@aggregated_value = Xpair::Literal.new(0)"
    options[:map] = "@aggregated_value.value += 1; @aggregated_value"
    options[:function_type] = Mapping::Aggregator
    options[:name] = "count_ud"
    

    
    origin_set = Xset.new("test", '') 
    
    origin_set.add_item Entity.new("_:i1")
    origin_set.add_item Entity.new("_:i2")
    origin_set.add_item Entity.new("_:i3")
    origin_set.add_item Entity.new("_:i4")

    # expected_pairs = Set.new([Pair.new(Xpair::Literal.new(4), Xpair::Literal.new(4))])

    # assert_equal expected_pairs, Set.new(origin_set.map{|mf| mf.count_ud(options)}.each_relation.first.each_pair)
    # assert_equal expected_pairs, Set.new(origin_set.map{|mf| mf.count_ud(options)}.each_relation.first.each_pair)
    rs = origin_set.map{|mf| mf.count_ud(options)}
    puts "test_ser_defined"
    puts rs.inspect
  end

end
