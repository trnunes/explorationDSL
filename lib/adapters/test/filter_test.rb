require "test/unit"
require "rdf"

require './mixins/xpair'
require './mixins/hash_explorable'
require './mixins/explorable'
require './mixins/auxiliary_operations'
require './mixins/enumerable'
require './mixins/persistable'
require './mixins/graph'

require './filters/filtering'
require './filters/contains'
require './filters/equals'
require './filters/keyword_match'
require './filters/match'
require './filters/in_range'
require './model/item'
require './model/xset'
require './model/literal'
require './model/entity'
require './model/relation'
require './model/type'
require './model/ranked_set'
require './model/namespace'

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'
require './aux/hash_helper'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/rdf_filter.rb'
require './adapters/rdf/rdf_nav_query.rb'
require './adapters/rdf/cache.rb'


class FilterTest < Test::Unit::TestCase
  
  def setup   

    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r2"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r3"), RDF::URI("_:o4")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:r4"), RDF::URI("_:o3")]
      graph << [RDF::URI("_:o3"),  RDF::URI("_:r5"), RDF::URI("_:o5")]      
      
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
      f.union do |u|
        u.equals(Entity.new("_:p1"))
        u.equals(Entity.new("_:p2"))
        u.equals(Entity.new("_:p3"))
        u.equals(Entity.new("_:p4"))
        
      end
      f.relation_equals([Entity.new("_:r1")], Entity.new("_:o1"))
    end
    expected_results = Set.new([Entity.new("_:p1")])
    
    assert_equal expected_results, filter.eval
    
    filter = @server.begin_filter do |f|
      f.relation_equals([Entity.new("_:r2")], Entity.new("_:o2"))
    end
    expected_results = Set.new([Entity.new("_:p1"), Entity.new("_:p2")])
    assert_equal expected_results, filter.eval
    
  end
  
  def test_relation_path_filter
    filter = @server.begin_filter do |f|

      f.relation_equals([Entity.new("_:r6"), Entity.new("_:r7")], Xpair::Literal.new("path"))
    end
  end
  
  def test_conjunctive_relation_filter
    filter = @server.begin_filter do |f|
      f.relation_equals([Entity.new("_:r1")], Entity.new("_:o1"))
      f.relation_equals([Entity.new("_:r2")], Entity.new("_:o2"))
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
      f.relation_equals([Entity.new("_:r1")], Entity.new("_:o1"))
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
      f.relation_equals([Entity.new("_:r2")], Entity.new("_:o2"))
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
      f.relation_equals([Entity.new("_:r1")], Entity.new("_:o2"))
      f.relation_equals([Entity.new("_:r2")], Entity.new("_:o2"))
    end
    
    expected_results = Set.new [Entity.new("_:p1")]    
    assert_equal expected_results, filter.eval
  end
  
  def test_disjunctive_relation_filter
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.relation_equals([Entity.new("_:r1")], Entity.new("_:o1"))
        u.relation_equals([Entity.new("_:r2")], Entity.new("_:o2"))
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
      f.relation_regex([Entity.new("_:r1")], "2")
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
        u.relation_regex([Entity.new("_:r1")], "1")
        u.relation_regex([Entity.new("_:r2")], "o2")
      end      
    end
    
    expected_results = Set.new [Entity.new("_:p1"), Entity.new("_:p2")]  
    assert_equal expected_results, filter.eval
  end
  
  def test_union_relation_regex_conjunction
    filter = @server.begin_filter do |f|
      f.union do |u|
        u.relation_regex([Entity.new("_:r1")], "1")
        u.relation_regex([Entity.new("_:r2")], "o2")
      end
      
      f.relation_equals([Entity.new("_:r1")], Entity.new("_:o2")) 
    end
    
    expected_results = Set.new [Entity.new("_:p1")]  
    assert_equal expected_results, filter.eval
  end
  
  
end