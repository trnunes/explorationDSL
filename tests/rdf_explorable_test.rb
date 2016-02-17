require "test/unit"
require "rdf/rdfset.rb"
require 'xset.rb'
class RDFExplorableTest < Test::Unit::TestCase
  
  def setup
    @dataset = RdfSet.new("rdf/test/elvis_subgraph.rdf")    
  end
  
  def test_pivot_single_relation
    rset = Xset.new("testSet")
    rset.original_set = @dataset
    rset << DataModel::Entity.new("http://dbpedia.org/resource/Elvis_Presley")
    relations = Xset.new("rel")
    relations << DataModel::Entity.new("http://dbpedia.org/ontology/birthPlace")

    expected_elements_set = [[DataModel::Entity.new("http://dbpedia.org/resource/Mississippi")]]
    actual_result_set = rset.pivot(relations)
    assert_equal(actual_result_set.elements, expected_elements_set)
    assert_equal(actual_result_set.original_set, @dataset)    
  end
  
  def test_refine_single_filter
    actual_results = @dataset.refine(lambda{|pair| pair.second_item.to_s == "http://dbpedia.org/resource/Mississippi"})

    expected_results = Xset.new("set")
    expected_results << DataModel::Relation.new(DataModel::Entity.new("http://dbpedia.org/resource/Elvis_Presley"),DataModel::Entity.new("http://dbpedia.org/resource/Mississippi"))    
    
    assert_equal(actual_results.elements, expected_results.elements)
  end
  
  def test_group_by_relation_image
    # expr = lambda do |item1, item2|
    #   if item1.second_item == item2.second_item
    #     return item1.second_item
    #   else
    #     return nil
    #   end
    # end
    #
    # actual_results = {}
    # result = @dataset.group_by(){|item1, item2| expr.call(item1, item2)}
    # result.each{|key, values| actual_results[key] = values.elements.uniq}
    # expected_result = {}
    #
    # expected_result[DataModel::Entity.new("o1")] = [
    #   DataModel::Relation.new(DataModel::Entity.new("p1"), DataModel::Entity.new("o1")),
    #   DataModel::Relation.new(DataModel::Entity.new("p2"), DataModel::Entity.new("o1")),
    #   DataModel::Relation.new(DataModel::Entity.new("p3"), DataModel::Entity.new("o1"))
    # ]
    #
    # expected_result[DataModel::Entity.new("o2")] = [
    #   DataModel::Relation.new(DataModel::Entity.new("p2"), DataModel::Entity.new("o2")),
    #   DataModel::Relation.new(DataModel::Entity.new("p3"), DataModel::Entity.new("o2")),
    #   DataModel::Relation.new(DataModel::Entity.new("p4"), DataModel::Entity.new("o2"))
    # ]
    #
    # assert_equal(actual_results, expected_result)
  end
  
  def test_find
    # actual_results = @dataset.find([[lambda{|item| item.id.include?("p1") || item.id == "p2"}, lambda{|item| item.id.include?("o1")}]])
    # expected_results = []
    # expected_results << DataModel::Relation.new(DataModel::Entity.new("p1"), DataModel::Entity.new("o1"))
    # expected_results << DataModel::Relation.new(DataModel::Entity.new("p2"), DataModel::Entity.new("o1"))
    #
    # assert_equal(actual_results.elements, expected_results)
    # 
  end
end