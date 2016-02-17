require "test/unit"
require "model/entity.rb"
require 'model/relation.rb'
require 'model/xset.rb'
require 'model/filter.rb'
require "FileUtils"

class ExplorableTest < Test::Unit::TestCase
  
  def setup
    @dataset = Xset.new("test_dataset")
    @dataset << Relation.new(Entity.new("p1"), Entity.new("o1"))
    @dataset << Relation.new(Entity.new("p2"), Entity.new("o1"))
    @dataset << Relation.new(Entity.new("p2"), Entity.new("o2"))
    @dataset << Relation.new(Entity.new("p3"), Entity.new("o1"))
    @dataset << Relation.new(Entity.new("p3"), Entity.new("o2"))
    @dataset << Relation.new(Entity.new("p4"), Entity.new("o2"))
    @dataset << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p1"), Entity.new("o1")))
    @dataset << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p2"), Entity.new("o1")))
    @dataset << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p2"), Entity.new("o2")))
    @dataset << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p3"), Entity.new("o1")))
    @dataset << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p3"), Entity.new("o2")))
    @dataset << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p4"), Entity.new("o2")))
    @dataset.save
    @correlate = Xset.new("correlate test")
    @correlate << Relation.new(Entity.new("o1"), Entity.new("p1"))    
    @correlate << Relation.new(Entity.new("o1"), Entity.new("p3"))
    @correlate << Relation.new(Entity.new("o2"), Entity.new("p3"))
    @correlate << Relation.new(Entity.new("p1"), Entity.new("p2"))
    @correlate << Relation.new(Entity.new("o2"), Entity.new("p2"))
  end
  
  def teardown
    begin
      FileUtils.rm("datasets/test_dataset.json")
      FileUtils.rm("datasets/entitySet.json")
    rescue Exception => e
    end
  end
  
  def test_pivot_single_relation
    test_set = Xset.new("test set")
    test_set.original_set = @dataset
    test_set << Entity.new("p1")
    test_set << Entity.new("p2")
    relation_set = Xset.new("relation test set")
    relation_set << Entity.new("hasOwner")
    
    expected_elements_set = [[Entity.new("o1")], [Entity.new("o1"), Entity.new("o2")]]
    actual_result_set = test_set.pivot(relation_set)
    assert_equal(actual_result_set.elements, expected_elements_set)
    assert_equal(actual_result_set.original_set, @dataset)
    assert_equal('Xset.load("test set").pivot(Xset.load("relation test set"))', actual_result_set.expression)
    
  end
  
  def test_refine_single_filter
    f = Filter.new('item.second_item == Entity.new("o1")')
    actual_results = @dataset.refine(f)
    expected_results = [
      Relation.new(Entity.new("p1"), Entity.new("o1")), 
      Relation.new(Entity.new("p2"), Entity.new("o1")), 
      Relation.new(Entity.new("p3"), Entity.new("o1"))
    ]
    actual_results.id = "refine"
    assert_equal(actual_results.elements, expected_results)
    assert_equal(actual_results.expression.gsub(" ", ""), 'Xset.load("test_dataset").refine(Filter.new("item.second_item==Entity.new("o1")"))')
  end
  
  def test_refine_entity_variable_in_filter
    a = Entity.new('o1')
    f = Filter.new("item.second_item == a", binding)
    actual_results = @dataset.refine(f)
    expected_results = [
      Relation.new(Entity.new("p1"), Entity.new("o1")), 
      Relation.new(Entity.new("p2"), Entity.new("o1")), 
      Relation.new(Entity.new("p3"), Entity.new("o1"))
    ]
    actual_results.id = "refine"
    assert_equal(actual_results.elements, expected_results)
    assert_equal(actual_results.expression.gsub(" ", ""), 'Xset.load("test_dataset").refine(Filter.new("item.second_item==Entity.new("o1")"))')
  end
  
  def test_refine_xset_variable_in_filter
    a = Xset.new("entitySet")
    a << Entity.new('o1')
    a << Entity.new('o8')
    a.save
    f = Filter.new("a.include?(item.second_item)", binding)
    actual_results = @dataset.refine(f)
    expected_results = [
      Relation.new(Entity.new("p1"), Entity.new("o1")), 
      Relation.new(Entity.new("p2"), Entity.new("o1")), 
      Relation.new(Entity.new("p3"), Entity.new("o1"))
    ]
    actual_results.id = "refine"
    assert_equal(actual_results.elements, expected_results)
    assert_equal(actual_results.expression.gsub(" ", ""), 'Xset.load("test_dataset").refine(Filter.new("Xset.load("entitySet").include?(item.second_item)"))')
  end  
  
  def test_refine_multiple_filters
    a = Xset.new("entitySet")
    a << Entity.new('o1')
    a.save
    p1 = Entity.new('p1')
    f1 = Filter.new("a.include?(item.second_item)", binding)
    f2 = Filter.new("item.first_item == p1", binding)
    actual_results = @dataset.refine(f1, f2)
    expected_results = [
      Relation.new(Entity.new("p1"), Entity.new("o1"))
    ]
    actual_results.id = "refine"
    assert_equal(actual_results.elements, expected_results)
    assert_equal(actual_results.expression.gsub(" ", ""), 'Xset.load("test_dataset").refine(Filter.new("Xset.load("entitySet").include?(item.second_item)"),Filter.new("item.first_item==Entity.new("p1")"))')
  end  
  
  def test_group_by_relation_image
    expr = lambda do |item1, item2|
      if item1.second_item == item2.second_item
        return item1.second_item
      else
        return nil
      end
    end
          
    actual_results = {}
    result = @dataset.group_by(){|item1, item2| expr.call(item1, item2)}
    # result.each{|group| puts group.to_s}
    
    group1 = [
      Relation.new(Entity.new("p1"), Entity.new("o1")),
      Relation.new(Entity.new("p2"), Entity.new("o1")),
      Relation.new(Entity.new("p3"), Entity.new("o1"))      
    ]
    
    group2 = [
      Relation.new(Entity.new("p2"), Entity.new("o2")),
      Relation.new(Entity.new("p3"), Entity.new("o2")),
      Relation.new(Entity.new("p4"), Entity.new("o2"))
    ]
    
    assert_equal(result.size, 2)
    assert_equal(Entity.new("o1"), result[0][0])
    assert_equal(Entity.new("o2"), result[1][0])
    assert_equal(group1, result[0][1].elements)
    assert_equal(group2, result[1][1].elements)
    
  end
  
  def test_find
    actual_results = @dataset.find([[lambda{|item| item.id.include?("p1") || item.id == "p2"}, lambda{|item| item.id.include?("o1")}]])
    expected_results = []
    expected_results << Relation.new(Entity.new("p1"), Entity.new("o1"))
    expected_results << Relation.new(Entity.new("p2"), Entity.new("o1"))    
    assert_equal(actual_results.elements, expected_results)    
  end
  
  def test_correlate
    actual_results = @correlate.correlate(Entity.new("o1"), Entity.new("o2"))
    expected_path1 = []
    expected_path1 << Relation.new(Entity.new("o1"), Entity.new("p3"))
    expected_path1 << Relation.new(Entity.new("o2"), Entity.new("p3"))    
    
    expected_path2 = []
    expected_path2 << Relation.new(Entity.new("o1"), Entity.new("p1"))
    expected_path2 << Relation.new(Entity.new("p1"), Entity.new("p2"))
    expected_path2 << Relation.new(Entity.new("o2"), Entity.new("p2"))

    assert_equal(2, actual_results.size)
    assert_equal(expected_path1, actual_results[0].elements)
    assert_equal(expected_path2, actual_results[1].elements)
    actual_results.id = "exp_test"
    assert_equal('Xset.load("correlate test").correlate(Entity.new("o1"),Entity.new("o2"),20)', actual_results.expression)

  end  
  
  def test_expression_compositions
    test_composition1 = Xset.new("test_composition1")
    test_composition1 << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p1"), Entity.new("o1")))
    test_composition1 << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p2"), Entity.new("o1")))
    test_composition1 << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p2"), Entity.new("o2")))
    
    test_composition2 = Xset.new("test_composition2")
    test_composition2 << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p3"), Entity.new("o1")))
    test_composition2 << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p3"), Entity.new("o2")))
    test_composition2 << Relation.new(Entity.new("hasOwner"), Relation.new(Entity.new("p4"), Entity.new("o2")))
    

    relation_set = Xset.new("relation test set")
    relation_set << Entity.new("hasOwner")
    
    expected_elements_set = [[Entity.new("o1")], [Entity.new("o1"), Entity.new("o2")], [Entity.new("o1"), Entity.new("o2")], [Entity.new("o2")]]
    actual_result_set = test_composition1.union(test_composition2).pivot(relation_set)
    assert_equal(actual_result_set.elements, expected_elements_set)
    assert_equal('Xset.load("test_composition1").union(Xset.load("test_composition2")).pivot(Xset.load("relation test set"))', actual_result_set.expression)
  end
  


end