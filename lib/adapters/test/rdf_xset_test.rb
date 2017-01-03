require "test/unit"
require "rdf"

require './mixins/hash_explorable'
require './mixins/enumerable'
require './mixins/persistable'
require './filters/filtering'
require './filters/contains'
require './filters/equals'
require './filters/keyword_match'
require './filters/match'
require './filters/in_range'
require './model/item'
require './model/xset'
require './model/entity'
require './model/ranked_set'

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/rdf_filter.rb'
require './adapters/rdf/rdf_nav_query.rb'

$PAGINATE = 10
##TODO BUGS TO CORRECT
## contains_one does not admit literals
##

class EndpointExplorationTest < Test::Unit::TestCase
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
  
  def test_relations
    test_set = Xset.new do |s|
      s.server = @server
      s.resulted_from = Xset.new
      s.extension = {
        Entity.new("_:p1") => {},
        Entity.new("_:p2") => {},
        Entity.new("_:p3") => {},
        Entity.new("_:p4") => {},
        Entity.new("_:p5") => {}        
      }
    end
    test_set.each
    
    expected_extension = {
      Entity.new("_:p1") => Set.new([Entity.new("_:r1")]),
      Entity.new("_:p2") => Set.new([Entity.new("_:r1")]),
      Entity.new("_:p3") => Set.new([Entity.new("_:r1")]),
      Entity.new("_:p4") => Set.new([Entity.new("_:r2")]),
      Entity.new("_:p5") => Set.new([Entity.new("_:r2")])      
    }
    
    assert_equal expected_extension, test_set.relations.extension
  end
  
  def test_domain
    test_set = Xset.new do |s|
      s.extension = { 
        Entity.new("_:p1") => [Entity.new("_:o1"), Entity.new("_:o2")],
        Entity.new("_:p2") => [Entity.new("_:o2")],
        Entity.new("_:p3") => [Entity.new("_:o3")]
      }     
    end
    
    test_set.server = @server
    
    expected_domain = Set.new [Entity.new("_:p1"), Entity.new("_:p2"),Entity.new("_:p3")]   
    
    assert_equal expected_domain, Set.new(test_set.each_domain    )
  end
  
  
  def test_image
    test_set = Xset.new do |s|
      s.extension = { 
        Entity.new("_:p1") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o1"), Entity.new("_:o2")])
        },
        Entity.new("_:p2") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o2")])
        },
        Entity.new("_:p3") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o3")])
        }
      }     
    end
    
    expected_image = Set.new [Entity.new("_:o1"), Entity.new("_:o2"), Entity.new("_:o3")] 
    assert_equal expected_image, Set.new(test_set.each_image)
  end
  
  def test_restricted_image
    test_set = Xset.new do |s|
      s.extension = { 
        Entity.new("_:p1") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o1"), Entity.new("_:o2")])
        },
        Entity.new("_:p2") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o2")])
        },
        Entity.new("_:p3") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o3")])
        }
      }     
    end
    
    expected_restricted_image_p1 = Set.new([Entity.new("_:o1"), Entity.new("_:o2")])
    expected_restricted_image_p2 = Set.new([Entity.new("_:o2")])
    expected_restricted_image_p3 = Set.new([Entity.new("_:o3")])
    
    assert_equal expected_restricted_image_p1, test_set.restricted_image([Entity.new("_:p1")])
    assert_equal expected_restricted_image_p2, test_set.restricted_image([Entity.new("_:p2")])
    assert_equal expected_restricted_image_p3, test_set.restricted_image([Entity.new("_:p3")])    
  end
  
  def test_restricted_domain
    test_set = Xset.new do |s|
      s.extension = { 
        Entity.new("_:p1") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o1"), Entity.new("_:o2")])
        },
        Entity.new("_:p2") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o2")])
        },
        Entity.new("_:p3") => {
          Entity.new("_:r1") => Set.new([Entity.new("_:o3")])
        }
      }     
    end
    
    expected_restricted_domain_o1 = Set.new([Entity.new("_:p1")])
    expected_restricted_domain_o2 = Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
    expected_restricted_domain_o3 = Set.new([Entity.new("_:p3")])

    assert_equal expected_restricted_domain_o1, test_set.restricted_domain([Entity.new("_:o1")])
    assert_equal expected_restricted_domain_o2, test_set.restricted_domain([Entity.new("_:o2")])
    assert_equal expected_restricted_domain_o3, test_set.restricted_domain([Entity.new("_:o3")])
  end
  
  # def test_pivot_no_relation
  #   test_set = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:p1") => [Entity.new("_:o1"), Entity.new("_:o2")],
  #       Entity.new("_:p2") => [Entity.new("_:o2")],
  #       Entity.new("_:p3") => [Entity.new("_:o3")]
  #     }
  #   end
  #
  #   test_set.server = @server
  #
  #   expected_image = Set.new([Entity.new("_:p1"), Entity.new("_:p2"),Entity.new("_:p3")])
  #   expected_domain = Set.new([Entity.new("_:o1"),Entity.new("_:o2"), Entity.new("_:o3")])
  #
  #   rs = test_set.pivot
  #
  #   assert_equal expected_image, Set.new(rs.each_image)
  #   assert_equal expected_domain, Set.new(rs.each_domain)
  # end
  #
  def test_pivot_forward
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server    

    expected_extension = { 
      Entity.new("_:p1") => {
        Entity.new("_:r1") => Set.new([Entity.new("_:o1"), Entity.new("_:o2")])
      },
      Entity.new("_:p2") => {
        Entity.new("_:r1") =>Set.new([Entity.new("_:o2")])
      },
      Entity.new("_:p3") => {
        Entity.new("_:r1") => Set.new([Entity.new("_:o3")])
      }
    }
    assert_equal expected_extension, set.pivot_forward(["_:r1"]).extension
  end
  
  def test_pivot_property_path
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:paper1") => {
        Entity.new("_:cite") => {
          Entity.new("_:p2") => {
            Entity.new("_:author") => Set.new([Entity.new("_:a1")])
          },
          Entity.new("_:p3") => {
            Entity.new("_:author") => Set.new([Entity.new("_:a2")])
          }, 
        },        
      },
      Entity.new("_:p6") => {
        Entity.new("_:cite") => {
          Entity.new("_:p2") => {
            Entity.new("_:author") => Set.new([Entity.new("_:a1")])
          },
          Entity.new("_:p3") => {
            Entity.new("_:author") => Set.new([Entity.new("_:a2")])
          }, 
          Entity.new("_:p5") => {
            Entity.new("_:author") => Set.new([Entity.new("_:a1"), Entity.new("_:a2")])
          },
        },        
      },
    }
    assert_equal expected_extension, set.pivot_forward([["_:cite", "_:author"]]).extension
  end
  
  def test_pivot_multiple_relations
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:paper1") => {
        Entity.new("_:cite") => Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4") ]),
        Entity.new("_:author") => Set.new([Entity.new("_:a1"), Entity.new("_:a2")])
      },
      Entity.new("_:p6") => {
        Entity.new("_:cite") => Set.new([Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p5") ]),
        Entity.new("_:author") => Set.new([Entity.new("_:a2")])
      }
    }
    assert_equal expected_extension, set.pivot_forward(["_:cite", "_:author"]).extension
  end
  
  
  def test_pivot_backward
    set = Xset.new do |s| 
      s << Entity.new("_:o1")
      s << Entity.new("_:o2")
      s.resulted_from =  Xset.new{|os| os.server = @server}
    end
    
    set.server = @server
    

    expected_extension = { 
      Entity.new("_:o1") => {
        Entity.new("_:r1")=>Set.new([Entity.new("_:p1")])
      },
      Entity.new("_:o2") => {
        Entity.new("_:r1")=>Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
      }
    }
    
    assert_equal expected_extension, set.pivot_backward(["_:r1"]).extension
  end
  
  def test_refine_equal
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.refine{|f| f.equals(Entity.new("_:p2"))}
    
    expected_extension = { 
      Entity.new("_:p2") => {}
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
    
    relation = set.refine{|f| f.match("_:p")}
    
    expected_extension = { 
      Entity.new("_:p1")=>{},
      Entity.new("_:p2")=>{},
      Entity.new("_:p3")=>{},      
    }   
    
    assert_equal expected_extension, relation.extension
  end

  def test_refine_relation_equal
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.refine{|f| f.equals("_:r1", "_:o2")}
    
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
    
    relation = set.refine{|f| f.match("_:r1", "2")}
    
    expected_extension = { 
     Entity.new("_:p1") => {},
     Entity.new("_:p2") => {}      
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
  
  def test_pivot_refine
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.pivot_forward(["_:r1"]).refine{|f| f.equals(Entity.new("_:o2"))}
    
    expected_extension = { 
      Entity.new("_:p1") => {
        Entity.new("_:r1") => Set.new([Entity.new("_:o2")])
      },
      Entity.new("_:p2") => {
        Entity.new("_:r1") => Set.new([Entity.new("_:o2")])
      } 
    }    
    assert_equal expected_extension, relation.extension
    
  end
  
  def test_group_by
    test_set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    test_set.server = @server
    
    rs = test_set.group("_:r1")
    
    expected_set = Xset.new do |s|
      s.extension = {
        Entity.new("_:o1") => {
          Entity.new("group")=> Set.new([Entity.new("_:p1")])
        },
        Entity.new("_:o2") => {
          Entity.new("group")=> Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
        },
        Entity.new("_:o3") => {
          Entity.new("group")=> Set.new([Entity.new("_:p3")])
        },
      }
    end
    
    assert_equal expected_set.extension, rs.extension
  end
    
  
  def test_merge
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1")])}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t2")])}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1"), Entity.new("_:t3")])}
      s.extension[Entity.new("_:i4")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1"), Entity.new("_:t4")])}
      s.id = "mid_set"
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
      s << Entity.new("_:i3")
      s << Entity.new("_:i4")
      s.generates << mid_set_1
      s.resulted_from = Xset.new
      s.id = "origin_set"
    end
    mid_set_1.resulted_from = origin_set
    expected_extension = {
     Entity.new("_:i1") => {
       Entity.new("_:r")=> Set.new([Entity.new("_:t1")])
     },
     Entity.new("_:i2") => {
       Entity.new("_:r")=> Set.new([Entity.new("_:t2")])
     },
     Entity.new("_:i3") => {
       Entity.new("_:r")=> Set.new([Entity.new("_:t1"), Entity.new("_:t3")])
     },
     Entity.new("_:i4") => {
       Entity.new("_:r")=> Set.new([Entity.new("_:t1"), Entity.new("_:t4")])
     }
    }
    assert_equal expected_extension, origin_set.merge(mid_set_1).extension
  end
  
  def test_merge_missing_image
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t2")])}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1"), Entity.new("_:t3")])}
      s.extension[Entity.new("_:i4")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1"), Entity.new("_:t4")])}

      s.id = "mid_set"
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
      s << Entity.new("_:i3")
      s.generates << mid_set_1
      s.resulted_from = Xset.new
      s.id = "origin_set"
    end
    
    mid_set_1.resulted_from = origin_set
    expected_extension = {
     Entity.new("_:i2") => {
       Entity.new("_:r")=>Set.new([Entity.new("_:t2")])},
     Entity.new("_:i3") => {
       Entity.new("_:r")=>Set.new([Entity.new("_:t1"), Entity.new("_:t3")])},
    }
    assert_equal expected_extension, origin_set.merge(mid_set_1).extension
  end
  
  def test_merge_twice
    target_set = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= {Entity.new("_:r")=>Set.new([Entity.new("_:u1")])}
      s.extension[Entity.new("_:t2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:u2")])}
      s.extension[Entity.new("_:t3")]= {Entity.new("_:r")=>Set.new([Entity.new("_:u3")])}
      s.extension[Entity.new("_:t4")]= {Entity.new("_:r")=>Set.new([Entity.new("_:u4")])}
      s.id = "target set"
    end
    
    mid_set_1 = Xset.new do |s|
      s.extension[Entity.new("_:i1")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1")])}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t2")])}
      s.extension[Entity.new("_:i3")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1"), Entity.new("_:t3")])}
      s.extension[Entity.new("_:i4")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t1"), Entity.new("_:t4")])}
      s.generates << target_set
      s.id = "mid_set"
    end
    
    origin_set = Xset.new do |s|
      s << Entity.new("_:i1")
      s << Entity.new("_:i2")
      s << Entity.new("_:i3")
      s << Entity.new("_:i4")
      s.generates << mid_set_1
      s.resulted_from = Xset.new
      s.id = "origin_set"
    end
    mid_set_1.resulted_from = origin_set
    target_set.resulted_from = mid_set_1
    local_path = origin_set.merge(mid_set_1).merge(target_set)
    expected_extension = {
     Entity.new("_:i1") => {
       Entity.new("_:r")=>{
         Entity.new("_:t1") => {
           Entity.new("_:r")=>Set.new([Entity.new("_:u1")])
           }
         }
       },
     Entity.new("_:i2") => {
       Entity.new("_:r")=>{
         Entity.new("_:t2") => {
           Entity.new("_:r")=>Set.new([Entity.new("_:u2")])
           }
         }
       },
     Entity.new("_:i3") => {
       Entity.new("_:r")=>{
        Entity.new("_:t1") => {
          Entity.new("_:r")=>Set.new([Entity.new("_:u1")])
        },
        Entity.new("_:t3") => {
          Entity.new("_:r")=>Set.new([Entity.new("_:u3")])
        }
       }
      },
      Entity.new("_:i4") => {
        Entity.new("_:r")=>{
          Entity.new("_:t1") => {
            Entity.new("_:r")=>Set.new([Entity.new("_:u1")])
            },          
          Entity.new("_:t4") => {
            Entity.new("_:r")=>Set.new([Entity.new("_:u4")])
          }
        }
      }        
    }

    assert_equal expected_extension, local_path.extension

  end
  
  # def test_find_path
  #
  #   correlate_test = Xset.new do |s|
  #     s << Entity.new("_:o1")
  #   end
  #
  #   correlate_target_test = Xset.new do |s|
  #     s << Entity.new("_:o2")
  #   end
  #
  #   correlate_target_test.server = @correlate_server
  #
  #   correlate_test.server = @correlate_server
  #
  #   actual_results = correlate_test.find_path(correlate_target_test)
  #
  #   expected_rs = Xset.new do |s|
  #     s.extension = {
  #       Entity.new("_:o1") => {
  #         Entity.new("_:p3") => Entity.new("_:o2"),
  #         Entity.new("_:p1") => {Entity.new("_:p2") => Entity.new("_:o2")}
  #       }
  #     }
  #   end
  #
  #   assert_equal expected_rs.extension, actual_results.extension
  # end
 
end