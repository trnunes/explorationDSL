require './test/xpair_unit_test'
class RDFDataServerTest < XpairUnitTest

  def setup

    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      
      graph << [RDF::URI("_:p1"),  RDF::RDFS.label, RDF::Literal('lp1')]
      graph << [RDF::URI("_:p2"),  RDF::RDFS.label, RDF::Literal('lp2')]
      graph << [RDF::URI("_:r1"),  RDF::RDFS.label, RDF::Literal('lr1')]
      graph << [RDF::URI("_:r2"),  RDF::RDFS.label, RDF::Literal('lr2')]
      graph << [RDF::URI("_:o1"),  RDF::RDFS.label, RDF::Literal('lo1')]
      graph << [RDF::URI("_:o2"),  RDF::RDFS.label, RDF::Literal('lo2')]



    end



    @server = RDFDataServer.new(@graph)
  end
#
#   def test_find_relations
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_nav_query do |t|
#       t.find_relations("_:p1")
#     end
#
#     result_hash = trans.execute()
#
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash, result_hash
#
#   end
#
#   def test_domain
#     expected_rs = [Entity.new("_:p1")]
#     actual_rs = @server.domain(Entity.new("_:r1"))
#     assert_equal expected_rs, actual_rs
#   end
#
#   def test_domain_regex
#     expected_rs = [Entity.new("_:p1")]
#     actual_rs = @server.domain(Entity.new("1"))
#     assert_equal expected_rs, actual_rs
#   end
#
#   def test_image
#     expected_rs = [Entity.new("_:o1"), Entity.new("_:o2")]
#     actual_rs = @server.image("_:r1").sort{|a,b| a.to_s<=>b.to_s}
#     assert_equal expected_rs, actual_rs
#   end
#
  def test_restricted_image_single
    expected_hash = {
      Entity.new("_:p1") => {
        Relation.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")]
      }
    }
    @server.label_property = RDF::RDFS.label.to_s
    trans = @server.begin_nav_query do |t|
      t.on(Entity.new("_:p1"))
      t.restricted_image("_:r1")
    end

    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Relation.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash, result_hash
    
    assert_equal "lp1", result_hash.keys.first.text
    assert_equal "lo1", result_hash[Entity.new("_:p1")][Relation.new("_:r1")][0].text
    assert_equal "lo2", result_hash[Entity.new("_:p1")][Relation.new("_:r1")][1].text
  end

  def test_cache_image
    expected_hash = {
      Entity.new("_:p1") => {
        Relation.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")]
      }
    }
    trans = @server.begin_nav_query do |t|
      t.on(Entity.new("_:p1"))
      t.restricted_image("_:r1")
    end

    result_hash = trans.execute()
    result_hash[Entity.new("_:p1")][Relation.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
    assert_equal expected_hash, result_hash
    puts "CACHE: " << @server.cache.inspect
    trans = @server.begin_nav_query do |t|
      t.on(Entity.new("_:p1"))
      t.restricted_image("_:r1")
    end
    puts "CACHE: "
    puts trans.execute.inspect
    
    
  end
  
  def test_cache_domain
    trans = @server.begin_nav_query do |t|
      t.on(Entity.new("_:o2"))
      t.restricted_domain("_:r2")
    end

    result_hash = trans.execute()

    puts "CACHE: " << @server.cache.inspect
    trans = @server.begin_nav_query do |t|
      t.on(Entity.new("_:o2"))
      t.restricted_domain("_:r2")
    end
    
    
    
  end
  
#
#   def test_restricted_image_union
#
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Relation.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
#         Relation.new("_:r2") => [Entity.new("_:o2")]
#       },
#
#       Entity.new("_:p2") => {
#         Relation.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_nav_query do |t|
#       t.on(Entity.new("_:p1")).on(Entity.new("_:p2"))
#       t.restricted_image("_:r1").restricted_image("_:r2")
#
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Relation.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#   def test_regex_filter
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Relation.new("_:r1") => [Entity.new("_:o2")],
#         Relation.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_query do |t|
#       t.on(Entity.new("_:p1")).on(Entity.new("_:p2"))
#       t.restricted_image("_:r1").restricted_image("_:r2")
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Relation.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#   def test_equal_filter
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Relation.new("_:r1") => [Entity.new("_:o2")],
#         Relation.new("_:r2") => [Entity.new("_:o2")]
#       }
#
#     }
#     trans = @server.begin_query do |t|
#       t.on(Entity.new("_:p1")).on(Entity.new("_:p2"))
#       t.filter_equals("_:r1", "_:o2")
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#   def test_conjunctive_filter
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Relation.new("_:r1") => [Entity.new("_:o2")],
#         Relation.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_query do |t|
#       t.on(Entity.new("_:p1")).on(Entity.new("_:p2"))
#       t.filter_regex("_:r1", "2").filter_regex("_:r2", "2")
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#   def test_disjunctive_filter
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Relation.new("_:r1") => [Entity.new("_:o2")],
#         Relation.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_query do |t|
#       t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
#       t.restricted_image("_:p2", "_:r2").filter_regex("_:r1", "2").filter_regex("_:r2", "2")
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#
#   end
#
#   def test_conjunctive_filter_regex_equals
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r1") => [Entity.new("_:o1")],
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_query do |t|
#       t.restricted_image("_:p1", "_:r1").restricted_image("_:p1", "_:r2")
#       t.restricted_image("_:p2", "_:r2").filter_equals("_:r1", "_:o1").filter_equals("_:r2", "_:o2")
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#   def test_filter_regex_all_items
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       },
#       Entity.new("_:p2") => {
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_query do |t|
#       t.filter_regex("_:r2", "2")
#     end
#     result_hash = trans.execute()
#
#     assert_equal expected_hash,  result_hash
#
#   end
#
#   def test_filter_equal_all_items
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       },
#       Entity.new("_:p2") => {
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_query do |t|
#       t.filter_equals("_:r2", "_:o2")
#     end
#     result_hash = trans.execute()
#
#     assert_equal expected_hash,  result_hash
#
#   end
#
#   def test_conjunctive_regex_all_items
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r1") => [Entity.new("_:o2")],
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       },
#     }
#     trans = @server.begin_query do |t|
#       t.filter_regex("_:r1", "2").filter_regex("_:r2", "2")
#     end
#     result_hash = trans.execute()
#
#     assert_equal expected_hash,  result_hash
#
#   end
#
#   def test_filter_on
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       },
#     }
#     trans = @server.begin_query do |t|
#       t.on(Entity.new("_:p1")).on(Entity.new("_:p2")).filter_regex("_:r1", "2")
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#   def test_filter_on2
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       },
#       Entity.new("_:p2") => {
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       }
#     }
#     trans = @server.begin_query do |t|
#       t.on(Entity.new("_:p1")).on(Entity.new("_:p2")).filter_regex("_:r2", "2")
#     end
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#   def test_filter_on_regex2
#     expected_hash = {
#       Entity.new("_:p1") => {
#         Entity.new("_:r1") => [Entity.new("_:o1"), Entity.new("_:o2")],
#         Entity.new("_:r2") => [Entity.new("_:o2")]
#       },
#     }
#
#     trans = @server.begin_query do |t|
#       t.on(Entity.new("_:p1")).on(Entity.new("_:p2")).filter_regex("_:r1", "2").filter_regex("_:r2", "2")
#     end
#
#     result_hash = trans.execute()
#     result_hash[Entity.new("_:p1")][Entity.new("_:r1")].sort!{|a, b| a.to_s <=> b.to_s }
#     assert_equal expected_hash,  result_hash
#   end
#
#
#

  def test_project
    set = Xset.new do |s|
      s.extension = {
        Entity.new("_:o1") => {},
        Entity.new("_:o2") => {},
      }
      s.server = @server
    end
    puts set.project(Relation.new(RDF::RDFS.label.to_s)).extension.inspect
  end

end