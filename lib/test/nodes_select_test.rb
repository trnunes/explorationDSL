require './test/xplain_unit_test'

require './operations/nodes_select'



class NodesSelectTest < XplainUnitTest
  
  def test_select_single_item
  
    input_nodes = create_nodes [
      Xplain::Entity.new('_:paper1'), Xplain::Entity.new('_:p2'), 
      Xplain::Entity.new('_:p4')
    ]
    node_p3 = Node.new(Xplain::Entity.new('_:p3'))
    input_nodes << node_p3
    input = Xplain::ResultSet.new(nil, input_nodes)
    result_set = input.nodes_select(["_:p3"]).execute()    
    
    assert_equal [node_p3], result_set.nodes
  end
  
  def test_select_multiple_items
    input_nodes = create_nodes [Xplain::Entity.new('_:p2')]
    
    node_p3 = Node.new(Xplain::Entity.new('_:p3'))
    node_p4 = Node.new(Xplain::Entity.new('_:p4'))
    node_paper1 = Node.new(Xplain::Entity.new('_:paper1'))
    
    input_nodes += [node_p3, node_p4, node_paper1]
    
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    result_set = input.nodes_select(["_:p3", "_:paper1", "_:p4"]).execute
    
    assert_equal Set.new([node_p3, node_p4, node_paper1]), Set.new(result_set.nodes)    
  end  

end