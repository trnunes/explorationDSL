require './test/xpair_unit_test'

class CompositionsTest < XpairUnitTest

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
    
  def test_select_pivot
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    s1 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:p2")=>{},Entity.new("_:p3")=>{},Entity.new("_:p5")=>{}}}
    s2 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:a2")=> {}}}
    s3 = Xsubset.new("key"){|s| s.extension = {Relation.new("_:cite") => s1, Relation.new("_:author")=>s2}}
    expected_extension = {
      Entity.new("_:p6") => s3
    }
    assert_equal expected_extension, set.select_items([Entity.new("_:p6")]).pivot.extension

  end
  
  def test_search_pivot_relations
    keywords = ["p"]
    set = Xset.new do |s|
      @papers_server.search(keywords).each do |item|      
        s << item     
      end
      s.server = @papers_server
    end
    years = set.pivot_forward(["_:publishedOn"]).pivot_forward(["_:releaseYear"])

    years.relations
  end
  
  def test_search_group
    keywords = ["p"]
    resourceset = Xset.new do |s|
      @papers_server.search(keywords).each do |item|      
        s << item     
      end
      s.server = @papers_server
    end
    resourceset.save
    Xset.load(resourceset.id).group{|gf| gf.by_relation(relations: [Relation.new('_:author')])}
  end
  
  def test_map_rank

    test_set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {},
        Entity.new("_:p2") => {}
      }
    end
    
    s1 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:i1") => {}, Entity.new("_:i2") => {}}}
    s2 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:i1") => {}, Entity.new("_:i2") => {}, Entity.new("_:i3") => {}}}
    s3 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:r") => s1}}
    s4 = Xsubset.new("key"){|s| s.extension = {Entity.new("_:r") => s2}}
    test_set2 = Xset.new do |s|
      s.extension ={
        Entity.new("_:p4") => s3,
        Entity.new("_:p2") => s4
      } 
      s.resulted_from = test_set1
    end

    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p4") => {}
    }

    assert_equal expected_extension, test_set1.rank{|rf| rf.by_relation(relations: [test_set1.map{|mf| mf.image_count([test_set2])}])}.extension

    
  end
  def test_group_by_twice_map_refine
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p5")=>{},
        Entity.new("_:p6")=>{}
      }
    end
    set.server = @papers_server
    set.save

    s1 = set.group{|gf| gf.by_relation(relations: [Relation.new("_:author")])}
    s1.save
    # s2 = s.group(level: 2){|gf| gf.by_relation(Relation.new("_:keywords"))}

    maps = s1.map{|mf| mf.count}
    maps.save



    s3 = s1.refine{|f| f.image_equals(relations: [maps], values: Xpair::Literal.new(9))}

  end
  
  def test_pivot_trace
    s = Xset.new{|s| s.extension = {Entity.new('_:p2') => {}, Entity.new('_:paper1') => {}}}
    s.server = @papers_server
    p = s.pivot_forward([Relation.new("_:cite")])
    s = p.each_image[0]
    domains = p.trace_domains(s)


  end
  
  def test_pivot_map_trace
    s = Xset.new{|s| s.extension = {Entity.new('_:p6') => {}, Entity.new('_:paper1') => {}}}
    s.id = "s1"
    s.server = @papers_server
    p1 = s.pivot_forward([Relation.new("_:cite")])
    p1.id = "p1"
    p2 = p1.map{|m| m.count}
    p2.id = "p2"
    i = p2.each_image[0]
    domains = p2.trace_domains(i)
    
    domains


  end
  
  def test_group_by_twice_map_trace_image
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p5")=>{},
        Entity.new("_:p6")=>{}
      }
      s.id = "setOrigin"
    end
    set.server = @papers_server
    set.save

    s1 = set.group{|gf| gf.by_relation(relations: [Relation.new("_:author")])}
    s1.id = "s1"
    s1.save


    s2 = s1.group(level: 2){|gf| gf.by_relation(relations: [Relation.new("_:keywords")])}
    s2.id = "s2"

    maps = s2.map{|mf| mf.count}



    maps.id = "map"
    maps.save
    rs = maps.trace_domains(maps.each_image.first)









    


    

  end
  
  def test_pivot_flatten_get_item
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p5")=>{},
        Entity.new("_:p6")=>{}
      }
      s.id = "setOrigin"
    end
    set.server = @papers_server
    rs = set.pivot_forward([Relation.new("_:author")]).flatten
    item = rs.get_item("_:a2")


    
  end
  def test_pivot_map_refine
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:p6")=>{},
        Entity.new("_:p7")=>{},
      }
      s.server = @papers_server
    end
    set.save
    
    s1 = set.pivot_forward([Relation.new("_:cite")])
    s1.save


    s2 = s1.map{|mf| mf.count}
    s2.save


    rs = set.refine{|rf| rf.image_equals(relations: [s2], values: Xpair::Literal.new(3))}
    expected_extension = {
      Entity.new("_:p6")=>{}
    }
    assert_equal expected_extension, rs.extension
  end
  
  def test_pivot_paginate
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    subset1 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:a1")=>{},
        Entity.new("_:a2")=>{}
      }
    end
    subset2 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p4")=>{}
      }
    end
    
    subset4 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:a2")=>{}
      }
    end
    subset8 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:journal1")=>{}
      }
    end
    
    subset5 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p5")=>{}
      }
    end
    subset7 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:k1")=>{},
        Entity.new("_:k2")=>{},
        Entity.new("_:k3")=>{}
      }
    end
    
    subset6 = Xsubset.new("key") do |s|
      s.extension = {
        Relation.new("_:author")=>subset4,
        Relation.new("_:cite")=> subset5,        
      }
    end
    subset3 = Xsubset.new("key") do |s|
      s.extension = {
        Relation.new("_:author")=>subset1,
        Relation.new("_:cite")=> subset2,
        Relation.new("_:keywords")=> subset7,
        Relation.new("_:submittedTo")=> subset8,
      }
    end

    expected_extension = {
      Entity.new("_:paper1")=> subset3,
      Entity.new("_:p6")=> subset6
    }
    rs = set.pivot()
    assert_equal expected_extension, rs.extension

    rs.each_image{|i| HashHelper.print_hash(i.extension)}
    assert_equal Set.new([subset1, subset2, subset4, subset5, subset7, subset8]), Set.new(rs.each_image)
    
  end
  
  def test_pivot_map_average
    set = Xset.new do |s|
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    subset2 = Xsubset.new("key") do |s|
      s.extension = {
        Entity.new("_:p2")=>{},
        Entity.new("_:p3")=>{},
        Entity.new("_:p5")=>{}
      }
    end
    subset3 = Xsubset.new("key") do |s|
      s.extension = {
        Relation.new("_:cite")=> subset2,
      }
    end
    expected_extension1 = {
      Entity.new("_:p6")=> subset3
    }
    
    expected_extension3 = {
    }
    
    rs1 = set.pivot_forward([Relation.new("_:cite")])
    rs2 = rs1.pivot_forward([Relation.new("_:publicationYear")])
    rs3 = rs2.map{|mf| mf.avg}


    assert_equal expected_extension3, rs3.extension
    
    
  end

end