require './test/xplain_unit_test'

class Xplain::KeywordSearchTest < XplainUnitTest
  module Xplain::Visualization
    label_for_type "http://www.w3.org/2000/01/rdf-schema#Resource", "http://www.w3.org/1999/02/22-rdf-syntax-ns#label"
  end
  
  def test_empty_keyword_phrase_nil
    @keyword_search_operation = Xplain::KeywordSearch.new()
    
    assert_raise MissingArgumentException do
      @keyword_search_operation.execute
    end    
    
  end

  def test_empty_keyword_phrase
    @keyword_search_operation = Xplain::KeywordSearch.new(keyword_phrase:  '')
    assert_raise MissingArgumentException do
      @keyword_search_operation.execute
    end    
  end
  
  def test_keyword_search_no_whole_dataset
    expected_results = Set.new(create_nodes [ Xplain::Entity.new('_:paper1')])
    
    @keyword_search_operation = Xplain::KeywordSearch.new(keyword_phrase:  'paper1_keyword')
    result_set =  @keyword_search_operation.execute
    
    assert_same_items_set expected_results, result_set.last_level    
  end
  
  def test_keyword_search_restricted_scope
    restriction_input = create_nodes [
      Xplain::Entity.new('_:paper1'), Xplain::Entity.new('_:p2'), 
      Xplain::Entity.new('_:p3'), Xplain::Entity.new('_:p4')
    ]
    input = Xplain::ResultSet.new(nodes:  restriction_input)
    
    @keyword_search_operation = Xplain::KeywordSearch.new(inputs: input, keyword_phrase:  'common_keyword')
    result_set =  @keyword_search_operation.execute
    
    assert_same_items_set input.last_level, result_set.last_level
  end
  
  def test_disjunctive_keyword_search
    expected_results = Set.new(create_nodes [ Xplain::Entity.new('_:p3'), Xplain::Entity.new('_:paper1')])
    @keyword_search_operation = Xplain::KeywordSearch.new(keyword_phrase:  'paper3_keyword|paper1_keyword')
    result_set =  @keyword_search_operation.execute
    assert_same_items_set expected_results, result_set.last_level
  end
  
  def test_conjunctive_keyword_search
    expected_results = Set.new(create_nodes [Xplain::Entity.new('_:p2')])
    @keyword_search_operation = Xplain::KeywordSearch.new(keyword_phrase:  'paper2_keyword1.*paper2_keyword2')
    result_set =  @keyword_search_operation.execute
    assert_same_items_set expected_results, result_set.last_level

  end
  
  def test_conjunctive_keyword_search_two_label_properties
    Xplain::Visualization.label_for_type( 
      "http://www.w3.org/2000/01/rdf-schema#Resource",
      "http://www.w3.org/1999/02/22-rdf-syntax-ns#label", 
      "_:alternative_label_property" 
    )
      
   
    expected_results = Set.new(create_nodes [Xplain::Entity.new('_:p3')])
    @keyword_search_operation = Xplain::KeywordSearch.new(keyword_phrase:  'common_keyword.*paper3_keyword2')
    result_set =  @keyword_search_operation.execute
    assert_same_items_set expected_results, result_set.last_level
  end
end