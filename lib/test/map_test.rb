require './test/xplain_unit_test'

class MapTest < XplainUnitTest

  def test_map_by_empty_input_set
    root = Xplain::ResultSet.new(nil, [])

    rs = Xplain::Xmap.new(inputs: root, mapping_relation: MapTo::Sum.new(Xplain::SchemaRelation.new(id: "_:cite"))).execute

    assert_true rs.to_tree.children.empty?, rs.inspect
  end

  def test_sum_by_single_relation_0
    input_nodes = create_nodes [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Xplain::Xmap.new(inputs: input, mapping_relation: MapTo::Sum.new(Xplain::SchemaRelation.new(id: "_:relevance"))).execute()
    
    assert_same_items_set rs.to_tree.children, input_nodes
    assert_true rs.to_tree.children.map{|n| n.children}.flatten.empty?
  end
  
  def test_sum_by_not_number
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    assert_raise NumericItemRequiredException do
      rs = Xplain::Xmap.new(inputs: input, mapping_relation: MapTo::Sum.new(Xplain::SchemaRelation.new(id: "_:cite"))).execute()
    end
  end
  
  def test_sum_single_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Xplain::Xmap.new(inputs: input, mapping_relation: MapTo::Sum.new(Xplain::SchemaRelation.new(id: "_:relevance"))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(30.0), Xplain::Literal.new(24.0), Xplain::Literal.new(20.0)]
    
    actual_rs_children = [p2.children[0], p3.children[0], p4.children[0]]
    
    assert_same_items_set expected_rs_children, actual_rs_children
  end
  
  def test_count_by_single_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Xplain::Xmap.new(inputs: input, mapping_relation: MapTo::Count.new(Xplain::SchemaRelation.new(id: "_:cite"))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p6 = rs.to_tree.children.select{|node| node.item.id == "_:p6"}[0]
    paper1 = rs.to_tree.children.select{|node| node.item.id == "_:paper1"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(0), Xplain::Literal.new(3), Xplain::Literal.new(3)]
    actual_rs_children = [p2.children[0], p6.children[0], paper1.children[0]]
    
    assert_same_items expected_rs_children, actual_rs_children
  end

  def test_count_by_inverse_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Xplain::Xmap.new(inputs: input, mapping_relation: MapTo::Count.new(Xplain::SchemaRelation.new(id: "_:cite", inverse: true))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    paper1 = rs.to_tree.children.select{|node| node.item.id == "_:paper1"}[0]
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(0), Xplain::Literal.new(2), Xplain::Literal.new(4)]
    actual_rs_children = [paper1.children[0], p2.children[0], p3.children[0]]
    
    assert_same_items expected_rs_children, actual_rs_children
  end
  
  def test_average
    require './operations/map_to/avg'
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Xplain::Xmap.new(inputs: input, mapping_relation: MapTo::Avg.new(Xplain::SchemaRelation.new(id: "_:relevance"))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(15.0), Xplain::Literal.new(12.0), Xplain::Literal.new(10.0)]
    actual_rs_children = [p2.children[0], p3.children[0], p4.children[0]]

    assert_same_items expected_rs_children, actual_rs_children
  end
  
  def test_count_computed_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    computed_relation = input.to_tree.get_level_relation(1)
    rs = Xplain::Xmap.new(inputs: input, level: 1, mapping_relation: MapTo::Count.new()).execute()
    assert_equal 1, rs.to_tree.children.size
    assert_same_items_set create_nodes([Xplain::Literal.new(3)]), rs.to_tree.children
    
  end
  
  def test_count_computed_relation_level_2
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input_nodes.first.children = create_nodes [Xplain::Entity.new("_:p2.1"), Xplain::Entity.new("_:p2.2"), Xplain::Entity.new("_:p2.3")]
    input_nodes[1].children = create_nodes [Xplain::Entity.new("_:p3.1"), Xplain::Entity.new("_:p3.2")]
    input_nodes[2].children = create_nodes [Xplain::Entity.new("_:p4.1")]
    
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    rs = Xplain::Xmap.new(inputs: input, level: 2, mapping_relation: MapTo::Count.new()).execute()
    assert_equal 3, rs.to_tree.children.size

    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}.first
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}.first
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}.first
    
    assert_same_items create_nodes([Xplain::Literal.new(3)]), p2.children
    
    assert_same_items create_nodes([Xplain::Literal.new(2)]), p3.children
    
    assert_same_items create_nodes([Xplain::Literal.new(1)]), p4.children
    
  end


  def test_count_computed_relation_level_2_dsl
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input_nodes.first.children = create_nodes [Xplain::Entity.new("_:p2.1"), Xplain::Entity.new("_:p2.2"), Xplain::Entity.new("_:p2.3")]
    input_nodes[1].children = create_nodes [Xplain::Entity.new("_:p3.1"), Xplain::Entity.new("_:p3.2")]
    input_nodes[2].children = create_nodes [Xplain::Entity.new("_:p4.1")]
    
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    rs = input.xmap(level: 2){count}.execute()
    assert_equal 3, rs.to_tree.children.size

    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}.first
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}.first
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}.first
    
    assert_same_items create_nodes([Xplain::Literal.new(3)]), p2.children
    
    assert_same_items create_nodes([Xplain::Literal.new(2)]), p3.children
    
    assert_same_items create_nodes([Xplain::Literal.new(1)]), p4.children
    
  end
  
  def test_sum_single_relation_dsl
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    rs = input.xmap do
      sum{relation "_:relevance"}      
    end.execute
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(30.0), Xplain::Literal.new(24.0), Xplain::Literal.new(20.0)]
    actual_rs_children = [p2.children[0], p3.children[0], p4.children[0]]
    
    assert_same_items_set expected_rs_children, actual_rs_children
  end
  
  def test_count_by_single_relation_dsl
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    rs = input.xmap do
      count{relation "_:cite"}      
    end.execute
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p6 = rs.to_tree.children.select{|node| node.item.id == "_:p6"}[0]
    paper1 = rs.to_tree.children.select{|node| node.item.id == "_:paper1"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(0), Xplain::Literal.new(3), Xplain::Literal.new(3)]
    actual_rs_children = [p2.children[0], p6.children[0], paper1.children[0]]
    
    assert_same_items expected_rs_children, actual_rs_children
  end

  def test_count_by_inverse_relation_dsl
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    rs = input.xmap do
      count{relation inverse("_:cite")}      
    end.execute
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    paper1 = rs.to_tree.children.select{|node| node.item.id == "_:paper1"}[0]
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(0), Xplain::Literal.new(2), Xplain::Literal.new(4)]
    actual_rs_children = [paper1.children[0], p2.children[0], p3.children[0]]
    
    assert_same_items expected_rs_children, actual_rs_children
  end

  
  def test_average_dsl
    
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = input.xmap do
      avg{relation "_:relevance"}      
    end.execute
    
    assert_equal 3, rs.to_tree.children.size
    assert_same_items_set input_nodes, rs.to_tree.children
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(15.0), Xplain::Literal.new(12.0), Xplain::Literal.new(10.0)]
    actual_rs_children = [p2.children[0], p3.children[0], p4.children[0]]
    
    assert_same_items expected_rs_children, actual_rs_children
  end

end