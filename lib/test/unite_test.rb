require './test/xplain_unit_test'


class Xplain::UniteTest < XplainUnitTest

  def test_empty_input_set
    input_nodes = []
    origin = Xplain::ResultSet.new(nil, input_nodes)
    
    actual_results = Xplain::Unite.new([origin, origin]).execute()
    assert_true actual_results.to_tree.children.empty?
  end

  def test_single_input
    input_nodes = create_nodes [Xplain::Entity.new("_:p1"), Xplain::Entity.new("_:p2")]
    origin = Xplain::ResultSet.new(nil, input_nodes)
    
    actual_results = Xplain::Unite.new([origin]).execute()
    assert_same_result_set origin, actual_results
  end
  
  def test_nil_input
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    
    actual_results = Xplain::Unite.new().execute()
    
  end
    
  def test_unite_1_height
    input1_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    input_1 = Xplain::ResultSet.new(nil, input1_nodes)

    input2_nodes = [
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3"))
    ]
    input_2 = Xplain::ResultSet.new(nil, input2_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:p1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])

    actual_results = Xplain::Unite.new([input_1, input_2]).execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
    
  end

  def test_unite_2_height
    i1p1 = Node.new(Xplain::Entity.new("_:p1"))
    i1p2 = Node.new(Xplain::Entity.new("_:p2"))
    i1p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.2"))]
    i1p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.2"))]
    input1 = Xplain::ResultSet.new(nil, [i1p1, i1p2])

    i2p1 = Node.new(Xplain::Entity.new("_:p1"))
    i2p2 = Node.new(Xplain::Entity.new("_:p2"))
    i2p3 = Node.new(Xplain::Entity.new("_:p3"))
    i2p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.3"))]
    i2p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.3"))]
    i2p3.children = [Node.new(Xplain::Entity.new("_:p3.1"))]
    input2 = Xplain::ResultSet.new(nil, [i2p1, i2p2, i2p3])
    
    expected_p1 = Node.new(Xplain::Entity.new("_:p1"))
    expected_p2 = Node.new(Xplain::Entity.new("_:p2"))
    expected_p3 = Node.new(Xplain::Entity.new("_:p3"))
    expected_p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.2")), Node.new(Xplain::Entity.new("_:p1.3"))]
    expected_p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.2")), Node.new(Xplain::Entity.new("_:p2.3"))]
    expected_p3.children = [Node.new(Xplain::Entity.new("_:p3.1"))]
    
    
    expected_output = Xplain::ResultSet.new(nil, [expected_p1, expected_p2, expected_p3])

    actual_results = Xplain::Unite.new([input1, input2]).execute()
    assert_false actual_results.to_tree.children.empty?
    
    assert_same_result_set expected_output, actual_results    
  end
    
end