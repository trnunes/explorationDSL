require "test/unit"
require "rdf"
require "./adapters/rdf/rdf_data_server"
require './model/entity'


class FilterTest < Test::Unit::TestCase
  
  def setup   

    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r2"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r3"), RDF::URI("_:o4")]
      
    end
    

    
    @server = RDFDataServer.new(@graph)
  end
  
  def test_union
    filter = @server.begin_filter do |f|      
      f.union do |u|
        u.equals(Entity.new("_:p1"))
        u.equals(Entity.new("_:p2"))
      end      
    end
    expected_results = Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
    
    
    assert_equal expected_results, filter.eval
  end
  
  def test_relation_filter
    filter = @server.begin_filter do |f|
      f.relation_equals(Entity.new("_:r1"), Entity.new("_:o1"))
    end
    expected_results = Set.new([Entity.new("_:p1")])
    
    assert_equal expected_results, filter.eval
    
    filter = @server.begin_filter do |f|
      f.relation_equals(Entity.new("_:r2"), Entity.new("_:o2"))
    end
    expected_results = Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
    assert_equal expected_results, filter.eval
    
  end
  
  def test_conjunctive_relation_filter
    filter = @server.begin_filter do |f|
      f.relation_equals(Entity.new("_:r1"), Entity.new("_:o1"))
      f.relation_equals(Entity.new("_:r2"), Entity.new("_:o2"))
    end
    expected_results = Set.new([Entity.new("_:p1")])
    
    assert_equal expected_results, filter.eval
  end
  
  def test_disjunctive_itens_conjunctive_relation
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.equals(Entity.new("_:p1"))
        u.equals(Entity.new("_:p2"))
      end
      f.relation_equals(Entity.new("_:r1"), Entity.new("_:o1"))
    end
    
    expected_results = Set.new [Entity.new("_:p1")]
    
    assert_equal expected_results, filter.eval
  end
  
  def test_disjunctive_itens_conjunctive_relation_two_items
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.equals(Entity.new("_:p1"))
        u.equals(Entity.new("_:p2"))
      end
      f.relation_equals(Entity.new("_:r2"), Entity.new("_:o2"))
    end
    
    expected_results = Set.new [Entity.new("_:p1"), Entity.new("_:p2")]    
    assert_equal expected_results, filter.eval
  end
  
  def test_disjunctive_itens_two_conjunctive_relation
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.equals(Entity.new("_:p1"))
        u.equals(Entity.new("_:p2"))
      end
      f.relation_equals(Entity.new("_:r1"), Entity.new("_:o2"))
      f.relation_equals(Entity.new("_:r2"), Entity.new("_:o2"))
    end
    
    expected_results = Set.new [Entity.new("_:p1")]    
    assert_equal expected_results, filter.eval
  end
  
  def test_disjunctive_relation_filter
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.relation_equals(Entity.new("_:r1"), Entity.new("_:o1"))
        u.relation_equals(Entity.new("_:r2"), Entity.new("_:o2"))
      end      
    end
    
    expected_results = Set.new [Entity.new("_:p1"), Entity.new("_:p2")]  
    assert_equal expected_results, filter.eval
  end
  
  def test_regex
    filter = @server.begin_filter do |f|      
      f.regex("2")
    end
    expected_results = Set.new([Entity.new("_:p2")])
    
    
    assert_equal expected_results, filter.eval
  end
  
  def test_relation_regex
    filter = @server.begin_filter do |f|      
      f.relation_regex(Entity.new("_:r1"), "2")
    end
    expected_results = Set.new([Entity.new("_:p1")])
    
    
    assert_equal expected_results, filter.eval
  end
  
  def test_union_regex
    filter = @server.begin_filter do |f|      
      f.union do |u|
        u.regex("p1")
        u.regex("p2")
      end      
    end
    expected_results = Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
    
    
    assert_equal expected_results, filter.eval
  end
  
  def test_union_relation_regex
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.relation_regex(Entity.new("_:r1"), "1")
        u.relation_regex(Entity.new("_:r2"), "o2")
      end      
    end
    
    expected_results = Set.new [Entity.new("_:p1"), Entity.new("_:p2")]  
    assert_equal expected_results, filter.eval
  end
  
  def test_union_relation_regex_conjunction
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.relation_regex(Entity.new("_:r1"), "1")
        u.relation_regex(Entity.new("_:r2"), "o2")
      end
      
      f.relation_equals(Entity.new("_:r1"), Entity.new("_:o2")) 
    end
    
    expected_results = Set.new [Entity.new("_:p1")]  
    assert_equal expected_results, filter.eval
  end
  
  
end