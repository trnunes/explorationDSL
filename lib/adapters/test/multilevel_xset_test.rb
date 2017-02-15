require "test/unit"
require "rdf"

require './mixins/hash_explorable'
require './mixins/auxiliary_operations'
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
require './model/relation'
require './model/type'
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
        Entity.new("_:p1") => {Entity.new("a1")},
        Entity.new("_:p2") => {Entity.new("a1")},
        Entity.new("_:p3") => {Entity.new("a1")},
        Entity.new("_:p4") => {Entity.new("a1")},
        Entity.new("_:p5") => {Entity.new("a1")}        
      }
    end
    test_set.each
    expected_extension = {
      Relation.new("_:r1") => {
        Entity.new("_:p1") => Relation.new("http://www.tecweb.inf.puc-rio.br/xpair/has_relation"),
        Entity.new("_:p2") => Relation.new("http://www.tecweb.inf.puc-rio.br/xpair/has_relation"),
        Entity.new("_:p3") => Relation.new("http://www.tecweb.inf.puc-rio.br/xpair/has_relation")
      },
      Relation.new("_:r2") => {
        Entity.new("_:p4") => Relation.new("http://www.tecweb.inf.puc-rio.br/xpair/has_relation"),
        Entity.new("_:p5") => Relation.new("http://www.tecweb.inf.puc-rio.br/xpair/has_relation")
      }
    }
    assert_equal expected_extension, test_set.relations.extension
  end
  
  def test_pivot_forward
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server    
    
    expected_extension = { 
      Entity.new("_:o1") => {Entity.new("_:p1")=>Relation.new("_:r1")},
      Entity.new("_:o2") => {
        Entity.new("_:p2") => Relation.new("_:r1"),
        Entity.new("_:p1") => Relation.new("_:r1")
      },
      Entity.new("_:o3") => {Entity.new("_:p3")=>Relation.new("_:r1")}
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
      Entity.new("_:a1") => {
        Entity.new("_:paper1") => {
          Relation.new("_:cite") => {
            Entity.new("_:p2")=>Relation.new("_:author")
          }
        },
        Entity.new("_:p6") => {
          Relation.new("_:cite") => {
            Entity.new("_:p2")=>Relation.new("_:author"),
            Entity.new("_:p5")=>Relation.new("_:author")
          }
        }
      },
      Entity.new("_:a2") => {
        Entity.new("_:paper1") => {
          Relation.new("_:cite") => {
            Entity.new("_:p3") => Relation.new("_:author")
          }
        },
        Entity.new("_:p6") => {
          Relation.new("_:cite") => {
            Entity.new("_:p3") => Relation.new("_:author"),
            Entity.new("_:p5") => Relation.new("_:author") 
          }
        }
      }
    }
    assert_equal expected_extension, set.pivot_forward([["_:cite", "_:author"]]).extension
  end
  def test_pivot_property_path_2
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
    expected_extension = {
      Entity.new("_:2010") => {
        Entity.new("_:paper1") => {
          Relation.new("_:cite") => {
            Entity.new("_:p2")=>Relation.new("_:author")
          }
        },
        Entity.new("_:p6") => {
          Relation.new("_:cite") => {
            Entity.new("_:p2")=>Relation.new("_:author"),
            Entity.new("_:p5")=>Relation.new("_:author")
          }
        }
      },
      Entity.new("_:a2") => {
        Entity.new("_:paper1") => {
          Relation.new("_:cite") => {
            Entity.new("_:p3") => Relation.new("_:author")
          }
        },
        Entity.new("_:p6") => {
          Relation.new("_:cite") => {
            Entity.new("_:p3") => Relation.new("_:author"),
            Entity.new("_:p5") => Relation.new("_:author") 
          }
        }
      }
    }
    # assert_equal expected_extension, set.pivot_forward([["_:publishedOn", "_:releaseYear"]]).extension
  end
  
  
  def test_select_pivot
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:a2") => {        
        Entity.new("_:p6") => Relation.new("_:author")
      },
      
      Entity.new("_:p2") => {
        Entity.new("_:p6") => Relation.new("_:cite")
      },
      
      Entity.new("_:p3") => {
        Entity.new("_:p6") => Relation.new("_:cite")
      },
      
      Entity.new("_:p5") => {
        Entity.new("_:p6") => Relation.new("_:cite")
      }
    }
    assert_equal expected_extension, set.select([Entity.new("_:p6")]).pivot.extension
    expected_relations_hash = {
      Relation.new("_:cite") => Set.new([Entity.new("_:p2"),Entity.new("_:p3"),Entity.new("_:p5")]),
      Relation.new("_:author") => Set.new([Entity.new("_:a2")]),
    }
    assert_equal expected_relations_hash, set.select([Entity.new("_:p6")]).pivot.relations_hash
  end
  
  def test_pivot_backward_relations
    set = Xset.new do |s|
      s << Entity.new("_:p2")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:a1") => {
        Entity.new("_:p2") => Relation.new("_:author")
      },
      Entity.new("_:journal1") => {
        Entity.new("_:p2") => Relation.new("_:publishedOn")
      },
      2000 => {
        Entity.new("_:p2") => Relation.new("_:publicationYear")
      },
      Entity.new("_:k3") => {
        Entity.new("_:p2") => Relation.new("_:keywords")
      },
      Entity.new("_:paper1") => {
        Entity.new("_:p2") => Relation.new("_:cite", true)
      },
      Entity.new("_:p6") => {
        Entity.new("_:p2") => Relation.new("_:cite", true)
      },
    }
    puts "test_pivot_backward_relations RESULT"
    set.pivot.extension.each do |item, relations|
      puts "item: " << item.to_s
      relations.each do |ritem, relation|
        puts "  "+ritem.to_s + ": " + relation.to_s
      end
    end
    assert_equal expected_extension, set.pivot.extension
  end
  
  def test_pivot_multiple_relations
    set = Xset.new do |s|
      s << Entity.new("_:paper1")
      s << Entity.new("_:p6")
    end
    set.server = @papers_server
    expected_extension = {
      Entity.new("_:a1") => {
        Entity.new("_:paper1") => Relation.new("_:author")
      },
            
      Entity.new("_:a2") => {
        Entity.new("_:paper1") => Relation.new("_:author"),
        Entity.new("_:p6") => Relation.new("_:author")
      },
      
      Entity.new("_:p2") => {
        Entity.new("_:paper1") => Relation.new("_:cite"),
        Entity.new("_:p6") => Relation.new("_:cite")
      },
      
      Entity.new("_:p3") => {
        Entity.new("_:paper1") => Relation.new("_:cite"),
        Entity.new("_:p6") => Relation.new("_:cite")
      },
      
      Entity.new("_:p4") => {
        Entity.new("_:paper1") => Relation.new("_:cite")
      },
      
      Entity.new("_:p5") => {
        Entity.new("_:p6") => Relation.new("_:cite")
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
      Entity.new("_:p1") => {
        Entity.new("_:o1") => Relation.new("_:r1", true),
        Entity.new("_:o2") => Relation.new("_:r1", true)
      },
      Entity.new("_:p2") => {        
        Entity.new("_:o2") => Relation.new("_:r1", true)
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
  
  def test_refine_equal_literal
    set = Xset.new do |s| 
      s << Entity.new("_:journal1")
      s << Entity.new("_:journal2")

    end
    
    set.server = @papers_server
    
    relation = set.refine{|f| f.equals(Entity.new("_:releaseYear"), "2005")}
    
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
  
  def test_refine_keyword_match
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:journal1")
      s << Entity.new("_:journal2")
    end
    
    set.server = @papers_server
    
    relation = set.refine{|f| f.keyword_match(['journal',])}
    
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
  
  def test_pivot_refine
    set = Xset.new do |s| 
      s << Entity.new("_:p1")
      s << Entity.new("_:p2")
      s << Entity.new("_:p3")
    end
    
    set.server = @server
    
    relation = set.pivot_forward(["_:r1"]).refine{|f| f.equals(Entity.new("_:o2"))}
    
    expected_extension = { 
      Entity.new("_:o2") => {
        Entity.new("_:p1") => Relation.new("_:r1"),
        Entity.new("_:p2") => Relation.new("_:r1")
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
          Entity.new("_:p1")=>Relation.new("_:r1", true)
        },
        Entity.new("_:o2") => {
          Entity.new("_:p1") => Relation.new("_:r1", true),
          Entity.new("_:p2") => Relation.new("_:r1", true)
        },
        Entity.new("_:o3") => {
          Entity.new("_:p3") => Relation.new("_:r1", true)
        },
      }
    end
    
    assert_equal expected_set.extension, rs.extension
  end
  
  def test_group_by_projection
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
          Entity.new("_:p1")=>Relation.new("_:r1", true)
        },
        Entity.new("_:o2") => {
          Entity.new("_:p1") => Relation.new("_:r1", true),
          Entity.new("_:p2") => Relation.new("_:r1", true)
        },
        Entity.new("_:o3") => {
          Entity.new("_:p3") => Relation.new("_:r1", true)
        },
      }
    end
    
    assert_equal expected_set.extension, rs.extension
    
    projection = {
      Entity.new("_:o1") => {
        Relation.new("_:r1", true) => Set.new([Entity.new("_:p1")])
      },
      Entity.new("_:o2") => {
        Relation.new("_:r1", true) => Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
      },
      Entity.new("_:o3") => {
        Relation.new("_:r1", true) => Set.new([Entity.new("_:p3")])
      },
      
    }
    assert_equal projection, rs.projection 
  end
  
  def test_select
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:a1") => {
          Entity.new("_:p2") => Relation.new("_:author")
        },
        Entity.new("_:journal1") => {
          Entity.new("_:p2") => Relation.new("_:publishedOn")
        },
        2000 => {
          Entity.new("_:p2") => Relation.new("_:publicationYear")
        },
        Entity.new("_:k3") => {
          Entity.new("_:p2") => Relation.new("_:keywords")
        },
        Entity.new("_:paper1") => {
          Entity.new("_:p2") => Relation.new("_:cite", true)
        },
        Entity.new("_:p6") => {
          Entity.new("_:p2") => Relation.new("_:cite", true)
        },
      }
    end
    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:k3") => {}
    }
    assert_equal expected_extension, set.select([Entity.new("_:p2"), Entity.new("_:k3")]).extension
    expected_extension = {
      Relation.new("_:cite", true) => {},
    }
    assert_equal expected_extension, set.select([Relation.new("_:cite", true)]).extension
    expected_extension = { }
    assert_equal expected_extension, set.select([Entity.new("strange_item")]).extension
    
  end
  
    
  
  def test_merge
    mid_set_1 = Xset.new do |s|      
      s.extension = {
        Entity.new("_:t1") => {
          Entity.new("_:i1") => Relation.new("_:r"),
          Entity.new("_:i3") => Relation.new("_:r"),
          Entity.new("_:i4") => Relation.new("_:r"),
        },
        Entity.new("_:t2") => {
          Entity.new("_:i2") => Relation.new("_:r")
        },
        Entity.new("_:t3") => {
          Entity.new("_:i3") => Relation.new("_:r")
        },
        Entity.new("_:t4") => {
          Entity.new("_:i4") => Relation.new("_:r")
        }
      }
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
  
  def test_pagination
    test_set = Xset.new do |s|
      s.server = @server
      s.resulted_from = Xset.new
      s.extension = {
        Entity.new("_:p1") => {},
        Entity.new("_:p2") => {},
        Entity.new("_:p3") => {},
        Entity.new("_:p4") => {},
        Entity.new("_:p5") => {},
        Entity.new("_:p6") => {},
        Entity.new("_:p7") => {},
        Entity.new("_:p8") => {},
        Entity.new("_:p9") => {},
        Entity.new("_:p10") => {}        
      }
    end
    test_set.paginate(1, 5);
    assert_equal 2, test_set.number_of_pages
    assert_equal 5, test_set.max_per_page
    assert_equal 0, test_set.offset
    assert_equal 4, test_set.limit
    assert_equal test_set.each_domain_paginated, Set.new([Entity.new("_:p1"),Entity.new("_:p2"), Entity.new("_:p3"), Entity.new("_:p4"), Entity.new("_:p5")])
    assert equal_streams?(test_set.each_item, { Entity.new("_:p1") => {},  Entity.new("_:p2") => {},  Entity.new("_:p3") => {},  Entity.new("_:p4") => {},  Entity.new("_:p5") => {}}.each)
    
    test_set.paginate(2, 5);
    assert_equal 2, test_set.number_of_pages
    assert_equal 5, test_set.max_per_page
    assert_equal 5, test_set.offset
    assert_equal 10, test_set.limit
    
    assert_equal test_set.each_domain_paginated, Set.new([Entity.new("_:p6"),Entity.new("_:p7"), Entity.new("_:p8"), Entity.new("_:p9"), Entity.new("_:p10")])
    assert equal_streams?(test_set.each_item, { Entity.new("_:p6") => {},  Entity.new("_:p7") => {},  Entity.new("_:p8") => {},  Entity.new("_:p9") => {},  Entity.new("_:p10") => {}}.each)
  end
  
  def equal_streams?(s1, s2)
    loop do
      e1 = s1.next rescue :eof
      e2 = s2.next rescue :eof
      return false unless e1 == e2
      return true if e1 == :eof
    end
  end
  
  def test_union
    set1 = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= {Entity.new("_:r")=>Set.new([Entity.new("_:u1")])}
      s.extension[Entity.new("_:t2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:u2")])}
      s.id = "target set"
    end
    
    set2 = Xset.new do |s|
      s.extension[Entity.new("_:t1")]= {Entity.new("_:r")=>Set.new([Entity.new("_:e1")])}
      s.extension[Entity.new("_:i2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t2")])}
      s.id = "mid_set"
    end
    expected_extension = {}

    expected_extension[Entity.new("_:t1")]= {Entity.new("_:r")=>Set.new([Entity.new("_:e1"), Entity.new("_:u1")])}
    expected_extension[Entity.new("_:t2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:u2")])}
    expected_extension[Entity.new("_:i2")]= {Entity.new("_:r")=>Set.new([Entity.new("_:t2")])}
    
    assert_equal expected_extension, set1.union(set2).extension

    
  end
  
  def test_search_pivot_relations()
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
    Xset.load(resourceset.id).group(Relation.new('_:author'))
  end
  
  def test_relation_eql
    assert_true !(Relation.new("id", true) == Relation.new("id", false))
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