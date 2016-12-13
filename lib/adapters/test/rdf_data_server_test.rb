require "test/unit"
require "rdf"
require "./adapters/rdf/rdf_data_server"
require './model/entity'


class RDFDataServerTest < Test::Unit::TestCase
  
  def setup   

    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r2"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      
    end
    

    
    @server = RDFDataServer.new(@graph)
  end
  
  def test_find_relations
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }
    }    
    trans = @server.begin_nav_query do |t|
      t.find_relations("_:p1")
    end
    
    result_hash = trans.execute()
    
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash, result_hash
    
  end  
  
  def test_domain
    expected_rs = [Entity.new("_:p1")]
    actual_rs = @server.domain(Entity.new("_:r1"))
    assert_equal expected_rs, actual_rs        
  end

  def test_domain_regex
    expected_rs = [Entity.new("_:p1")]
    actual_rs = @server.domain(Entity.new("1"))
    assert_equal expected_rs, actual_rs        
  end
  
  def test_image
    expected_rs = [Entity.new("_:o1"), Entity.new("_:o2")]
    actual_rs = @server.image("_:r1").sort{|a,b| a.to_s<=>b.to_s}
    assert_equal expected_rs, actual_rs    
  end

  def test_restricted_image_single
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")]
      }
    }
    trans = @server.begin_nav_query do |t|
      t.restricted_image("_:p1", "_:r1")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash, result_hash
  end
  
  def test_restricted_image_union
    
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      },
      
      Entity.new("_:p2") => {        
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }      
    }
    trans = @server.begin_nav_query do |t|
      t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
      t.restricted_image("_:p2", "_:r2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  def test_regex_filter
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }      
    }
    trans = @server.begin_query do |t|
      t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
      t.restricted_image("_:p2", "_:r2").filter_regex("_:r1", "2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  def test_equal_filter
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }      
      
    }
    trans = @server.begin_query do |t|
      t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
      t.restricted_image("_:p2", "_:r2").filter_equals("_:r1", "_:o2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  def test_conjunctive_filter
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }      
    }
    trans = @server.begin_query do |t|
      t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
      t.restricted_image("_:p2", "_:r2").filter_regex("_:r1", "2").filter_regex("_:r2", "2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  def test_disjunctive_filter
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }      
    }
    trans = @server.begin_query do |t|
      t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
      t.restricted_image("_:p2", "_:r2").filter_regex("_:r1", "2").filter_regex("_:r2", "2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
    
  end
  
  def test_conjunctive_filter_regex_equals
    expected_hash = {
      Entity.new("_:p1") => {
        Entity.new("_:r1") => [Entity.new("_:o1")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }      
    }
    trans = @server.begin_query do |t|
      t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
      t.restricted_image("_:p2", "_:r2").filter_equals("_:r1", "_:o1").filter_equals("_:r2", "_:o2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  def test_filter_regex_all_items
    expected_hash = {
      Entity.new("_:p1") => {      
        Entity.new("_:r2") => [Entity.new("_:o2")]
      },
      Entity.new("_:p2") => {      
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }       
    }
    trans = @server.begin_query do |t|
      t.filter_regex("_:r2", "2")
    end
    result_hash = trans.execute()

    assert_equal expected_hash,  result_hash
    
  end
  
  def test_filter_equal_all_items
    expected_hash = {
      Entity.new("_:p1") => {      
        Entity.new("_:r2") => [Entity.new("_:o2")]
      },
      Entity.new("_:p2") => {      
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }       
    }
    trans = @server.begin_query do |t|
      t.filter_equals("_:r2", "_:o2")
    end
    result_hash = trans.execute()

    assert_equal expected_hash,  result_hash
    
  end
  
  def test_conjunctive_regex_all_items
    expected_hash = {
      Entity.new("_:p1") => {      
        Entity.new("_:r1") => [Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      },
    }
    trans = @server.begin_query do |t|
      t.filter_regex("_:r1", "2").filter_regex("_:r2", "2")
    end
    result_hash = trans.execute()

    assert_equal expected_hash,  result_hash
    
  end
  
  def test_filter_on
    expected_hash = {
      Entity.new("_:p1") => {      
        Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      },
    }
    trans = @server.begin_query do |t|
      t.on(Entity.new("_:p1")).on(Entity.new("_:p2")).filter_regex("_:r1", "2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  def test_filter_on2
    expected_hash = {
      Entity.new("_:p1") => {      
        Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      },
      Entity.new("_:p2") => {      
        Entity.new("_:r2") => [Entity.new("_:o2")]
      }      
    }
    trans = @server.begin_query do |t|
      t.on(Entity.new("_:p1")).on(Entity.new("_:p2")).filter_regex("_:r2", "2")
    end
    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  def test_filter_on_regex2
    expected_hash = {
      Entity.new("_:p1") => {      
        Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
        Entity.new("_:r2") => [Entity.new("_:o2")]
      },
    }
    
    trans = @server.begin_query do |t|
      t.on(Entity.new("_:p1")).on(Entity.new("_:p2")).filter_regex("_:r1", "2").filter_regex("_:r2", "2")
    end

    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash,  result_hash
  end
  
  
  
end