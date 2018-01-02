require './test/xplain_unit_test'
require './operations/unite'

class UniteTest < XplainUnitTest

  def test_empty_input_set
    input_nodes = []
    origin = Node.new(Xplain::Entity.new("root"))
    origin.children = input_nodes
    
    actual_results = Unite.new(input: [origin, origin]).execute()
    assert_true actual_results.children.empty?
  end

  def test_single_input
    input_nodes = create_nodes [Xplain::Entity.new("_:p1"), Xplain::Entity.new("_:p2")]
    origin = Node.new(Xplain::Entity.new("root"))
    origin.children = input_nodes
    
    actual_results = Unite.new(input: [origin]).execute()
    assert_equal origin.children, actual_results.children
  end
  
  def test_nil_input
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    
    begin
      actual_results = Unite.new().execute()
      assert false
    rescue InvalidInputException => e
      assert true
      return
    end
    assert false
    
  end
    
  def test_unite_1_height
    input1_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    input_1 = Node.new(Xplain::Entity.new("root"))
    input_1.children = input1_nodes

    input2_nodes = [
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3"))
    ]
    input_2 = Node.new(Xplain::Entity.new("root"))
    input_2.children = input2_nodes
    
    
    expected_results = Set.new([Xplain::Entity.new("_:p1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])

    actual_results = Unite.new(input: [input_1, input_2]).execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
    
  end

  def test_unite_2_height
    i1p1 = Node.new(Xplain::Entity.new("_:p1"))
    i1p2 = Node.new(Xplain::Entity.new("_:p2"))
    i1p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.2"))]
    i1p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.2"))]
    input1 = Node.new('root1')
    input1.children = [i1p1, i1p2]

    i2p1 = Node.new(Xplain::Entity.new("_:p1"))
    i2p2 = Node.new(Xplain::Entity.new("_:p2"))
    i2p3 = Node.new(Xplain::Entity.new("_:p3"))
    i2p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.3"))]
    i2p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.3"))]
    i2p3.children = [Node.new(Xplain::Entity.new("_:p3.1"))]
    input2 = Node.new('root2')
    input2.children = [i2p1, i2p2, i2p3]
    
    expected_p1 = Node.new(Xplain::Entity.new("_:p1"))
    expected_p2 = Node.new(Xplain::Entity.new("_:p2"))
    expected_p3 = Node.new(Xplain::Entity.new("_:p3"))
    expected_p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.2")), Node.new(Xplain::Entity.new("_:p1.3"))]
    expected_p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.2")), Node.new(Xplain::Entity.new("_:p2.3"))]
    expected_p3.children = [Node.new(Xplain::Entity.new("_:p3.1"))]
    
    
    expected_output = [expected_p1, expected_p2, expected_p3]

    actual_results = Unite.new(input: [input1, input2]).execute()
    assert_false actual_results.children.empty?
    assert_equal Set.new(expected_output), Set.new(actual_results.children)
    
    actual_p1 = actual_results.children.select{|child| child == i1p1}[0]
    actual_p2 = actual_results.children.select{|child| child == i1p2}[0]
    actual_p3 = actual_results.children.select{|child| child == i2p3}[0]

    assert_equal Set.new(actual_p1.children), Set.new(expected_p1.children)
    assert_equal Set.new(actual_p2.children), Set.new(expected_p2.children)
    assert_equal Set.new(actual_p3. children), Set.new(expected_p3.children)
    
  end
  

    
end