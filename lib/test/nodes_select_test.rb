require './test/xplain_unit_test'
class Xplain::NodesSelectTest < XplainUnitTest
  
  def test_select_single_item
  
    input_nodes = create_nodes [
      Xplain::Entity.new('_:paper1'), Xplain::Entity.new('_:p2'), 
      Xplain::Entity.new('_:p4')
    ]
    node_p3 = Xplain::Node.new(Xplain::Entity.new('_:p3'))
    input_nodes << node_p3
    input = Xplain::ResultSet.new(nil, input_nodes)
    result_set = input.nodes_select(ids: ["_:p3"]).execute()    
    
    expected_rs = Xplain::ResultSet.new("rs", [Xplain::Node.new(Xplain::Entity.new('_:p3'))])
    assert_same_result_set expected_rs, result_set
  end
  
  def test_select_multiple_items
    input_nodes = create_nodes [Xplain::Entity.new('_:p2')]
    
    node_p3 = Xplain::Node.new(Xplain::Entity.new('_:p3'))
    node_p4 = Xplain::Node.new(Xplain::Entity.new('_:p4'))
    node_paper1 = Xplain::Node.new(Xplain::Entity.new('_:paper1'))
    
    input_nodes += [node_p3, node_p4, node_paper1]
    
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    result_set = input.nodes_select(ids: ["_:p3", "_:paper1", "_:p4"]).execute
    expected_nodes = [Xplain::Node.new(Xplain::Entity.new('_:p3')), Xplain::Node.new(Xplain::Entity.new('_:p4')), Xplain::Node.new(Xplain::Entity.new('_:paper1'))]
    assert_same_result_set Xplain::ResultSet.new("rs", expected_nodes), result_set    
  end  

end