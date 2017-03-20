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
  

  def test_pivot_refine
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.pivot_forward(["_:r1"]).refine{|f| f.equals(values: Entity.new("_:o2"))}
    
    expected_extension = { 
      Entity.new("_:o2") => {}
    }    
    assert_equal expected_extension, relation.extension
    
  end
  
  def test_select_pivot
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:p6") =>{
        Relation.new("_:cite") => {Entity.new("_:p2")=>{},Entity.new("_:p3")=>{},Entity.new("_:p5")=>{}},
        Relation.new("_:author") => {Entity.new("_:a2")=> {}}
      }
    }
    assert_equal expected_extension, set.select([Entity.new("_:p6")]).pivot.extension

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
    Xset.load(resourceset.id).group{|gf| gf.by_relation(Relation.new('_:author'))}
  end
  
  def test_map_rank

    test_set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {},
        Entity.new("_:p2") => {}
      }
    end
    test_set2 = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {
          Entity.new("r")=> {
            Entity.new("_:i1") => {},
            Entity.new("_:i2") => {}
          }
        },
        Entity.new("_:p2") => {
          Entity.new("r")=> {
            Entity.new("_:i1") => {},
            Entity.new("_:i2") => {},
            Entity.new("_:i3") => {}
          }
        },
      }
      s.relation_index ={
        Entity.new("_:p4") => {
          Xsubset.new(test_set2, 0) do |ss|
            ss.extension = {
              Entity.new("r")=> {
                Entity.new("_:i1") => {},
                Entity.new("_:i2") => {},

              }
            }
          end => {}
        },
        Entity.new("_:p2") => {
          Xsubset.new(test_set2, 0) do |ss|
            ss.extension = {
              Entity.new("r")=> {
                Entity.new("_:i1") => {},
                Entity.new("_:i2") => {},
                Entity.new("_:i3") => {}
              }
            }
          end => {}
        },        
      } 
      s.resulted_from = test_set1
    end

    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p4") => {}
    }

    assert_equal expected_extension, test_set1.rank{|rf| rf.by_relation([test_set1.map{|mf| mf.image_count([test_set2])}])}.extension

    
  end
  def test_group_by_twice_map_refine
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:p2")=>{}
        Entity.new("_:p3")=>{}
        Entity.new("_:p5")=>{}
        Entity.new("_:p6")=>{}
      }
    end

    s1 = set.group{|gf| gf.by_relation(Relation.new("_:author"))}
    # s2 = s.group(level: 2){|gf| gf.by_relation(Relation.new("_:keywords"))}
    maps = s1.map(level: 2){|mf| mf.count}
    s3 = s2.refine(level: 2){|f| f.image_equals([maps], Literal.new(2))}
  end
  def test_pivot_map_rank2
    test_set1 = Xset.new do |s|
      s.extension = {
        Entity.new("_:p4") => {},
        Entity.new("_:p2") => {}
      }
    end
    test_set1.server = @papers_server
    
    
  end
    

end