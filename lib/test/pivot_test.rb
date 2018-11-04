require './test/xplain_unit_test'
require './operations/pivot'

class PivotTest < XplainUnitTest

  def test_empty_input_set
    input_nodes = []
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    
    actual_results = Pivot.new(root,  relation: Xplain::SchemaRelation.new(id: "_:r1")).execute()
    assert_true actual_results.to_tree.children.empty?
  end
  
  def test_empty_relation
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    
    begin
      actual_results = Pivot.new(root).execute()
      assert false
    rescue MissingRelationException => e
      assert true
      return
    end
    assert false
    
  end
  
  def test_empty_output
    input_nodes = [
      Node.new(Xplain::Entity.new("_:notexist1")),
      Node.new(Xplain::Entity.new("_:notexist2"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    

    actual_results = Pivot.new(root,  relation: Xplain::SchemaRelation.new(id:"_:r1")).execute()
    assert_true actual_results.to_tree.children.empty?
  end
  
  def test_pivot_single_relation
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    
    expected_results = Set.new([Xplain::Entity.new("_:o1"), Xplain::Entity.new("_:o2")])

    actual_results = Pivot.new(root, server: @server, relation: Xplain::SchemaRelation.new(id:"_:r1", server: @server)).execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
    
  end
  
  def test_pivot_single_relation_inverse
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    
    expected_results = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8")])

    actual_results = Pivot.new(root,  relation: Xplain::SchemaRelation.new(id:"_:cite", inverse: true)).execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end

  def test_pivot_relation_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p6"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")])
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite"), Xplain::SchemaRelation.new(id: "_:author")])
    actual_results = Pivot.new(root,  relation: path).execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end
  
  
  def test_pivot_backward_relation_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:a1"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:author", inverse: true), Xplain::SchemaRelation.new(id: "_:cite", inverse: true)])
    expected_results = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")])

    actual_results = Pivot.new(root,  relation: path).execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end
    
  def test_pivot_forward_backward_relation_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:journal1"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    
    expected_results = Set.new([Xplain::Entity.new("_:a1")])
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:publishedOn", inverse: true), Xplain::SchemaRelation.new(id: "_:author")])
    actual_results = Pivot.new(root,  relation: path).execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end
  
  def test_pivot_direct_computed_relation
    i1p1 = Node.new(Xplain::Entity.new("_:p1"))
    i1p2 = Node.new(Xplain::Entity.new("_:p2"))
    i1p3 = Node.new(Xplain::Entity.new("_:p3"))
    i1p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.2"))]
    i1p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.2"))]
    i1p3.children = [Node.new(Xplain::Entity.new("_:p3.1"))]
    computed_relation = Xplain::ResultSet.new(nil, [i1p1, i1p2, i1p3])
    
    input = Xplain::ResultSet.new(nil, [Node.new(Xplain::Entity.new("_:p1"))])
    
    expected_rs = Xplain::ResultSet.new(nil, i1p1.children)
    
    assert_same_result_set expected_rs, input.pivot{relation computed_relation}.execute
    
    input = Xplain::ResultSet.new(nil, [Node.new(Xplain::Entity.new("_:p1")), Node.new(Xplain::Entity.new("_:p2"))])
    
    expected_rs = Xplain::ResultSet.new(nil, i1p1.children + i1p2.children)
    
    assert_same_result_set expected_rs, input.pivot{relation computed_relation}.execute
  end
  
  def test_pivot_inverse_computed_relation
    i1p1 = Node.new(Xplain::Entity.new("_:p1"))
    i1p2 = Node.new(Xplain::Entity.new("_:p2"))
    i1p3 = Node.new(Xplain::Entity.new("_:p3"))
    i1p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.2"))]
    i1p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.2"))]
    i1p3.children = [Node.new(Xplain::Entity.new("_:p3.1"))]
    computed_relation = Xplain::ResultSet.new(nil, [i1p1, i1p2, i1p3])
    
    input = Xplain::ResultSet.new(nil, [Node.new(Xplain::Entity.new("_:p1.2"))])
    
    expected_rs = Xplain::ResultSet.new(nil, [i1p1])
    
    assert_same_result_set expected_rs, input.pivot{relation inverse: computed_relation}.execute
    
    input = Xplain::ResultSet.new(nil, [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p3.1"))])
    
    expected_rs = Xplain::ResultSet.new(nil, [i1p1, i1p3])
    
    assert_same_result_set expected_rs, input.pivot{relation inverse: computed_relation}.execute
  end
 
end