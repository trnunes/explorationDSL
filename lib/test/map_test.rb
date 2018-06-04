require './test/xplain_unit_test'
require './operations/map'
require './operations/mapping_functions/avg'
require './operations/mapping_functions/count'
require './operations/mapping_functions/sum'

class MapTest < XplainUnitTest

  def test_map_by_empty_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2")]
    
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    assert_raise MissingAuxiliaryFunctionException do
      rs = Map.new(input: input).execute
    end
  end
    
  def test_map_by_empty_input_set
    root = Xplain::ResultSet.new(nil, [])

    rs = Map.new(input: root, mapping_relation: Mapping::Sum.new(Xplain::SchemaRelation.new(id: "_:cite"))).execute

    assert_true rs.to_tree.children.empty?, rs.inspect
  end

  def test_sum_by_single_relation_0
    input_nodes = create_nodes [Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Map.new(input: input, mapping_relation: Mapping::Sum.new(Xplain::SchemaRelation.new(id: "_:relevance"))).execute()
    
    assert_equal rs.to_tree.children, input_nodes
    assert_true rs.to_tree.children.map{|n| n.children}.flatten.empty?
  end
  
  def test_sum_by_not_number
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    assert_raise NumericItemRequiredException do
      rs = Map.new(input: input, mapping_relation: Mapping::Sum.new(Xplain::SchemaRelation.new(id: "_:cite"))).execute()
    end
  end
  
  def test_sum_single_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Map.new(input: input, mapping_relation: Mapping::Sum.new(Xplain::SchemaRelation.new(id: "_:relevance"))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_equal Set.new(input_nodes), Set.new(rs.to_tree.children)
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(30.0), Xplain::Literal.new(24.0), Xplain::Literal.new(20.0)]
    actual_rs_children = [p2.children[0], p3.children[0], p4.children[0]]
    
    assert_equal expected_rs_children, actual_rs_children
  end
  
  def test_count_by_single_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:paper1")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Map.new(input: input, mapping_relation: Mapping::Count.new(Xplain::SchemaRelation.new(id: "_:cite"))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_equal Set.new(input_nodes), Set.new(rs.to_tree.children)
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p6 = rs.to_tree.children.select{|node| node.item.id == "_:p6"}[0]
    paper1 = rs.to_tree.children.select{|node| node.item.id == "_:paper1"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(0), Xplain::Literal.new(3), Xplain::Literal.new(3)]
    actual_rs_children = [p2.children[0], p6.children[0], paper1.children[0]]
    
    assert_equal expected_rs_children, actual_rs_children
  end

  def test_count_by_inverse_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Map.new(input: input, mapping_relation: Mapping::Count.new(Xplain::SchemaRelation.new(id: "_:cite", inverse: true))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_equal Set.new(input_nodes), Set.new(rs.to_tree.children)
    
    paper1 = rs.to_tree.children.select{|node| node.item.id == "_:paper1"}[0]
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(0), Xplain::Literal.new(2), Xplain::Literal.new(4)]
    actual_rs_children = [paper1.children[0], p2.children[0], p3.children[0]]
    
    assert_equal expected_rs_children, actual_rs_children
  end
  
  def test_average
    
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    
    
    rs = Map.new(input: input, mapping_relation: Mapping::Avg.new(Xplain::SchemaRelation.new(id: "_:relevance"))).execute()
    
    assert_equal 3, rs.to_tree.children.size
    assert_equal Set.new(input_nodes), Set.new(rs.to_tree.children)
    
    p2 = rs.to_tree.children.select{|node| node.item.id == "_:p2"}[0]
    p3 = rs.to_tree.children.select{|node| node.item.id == "_:p3"}[0]
    p4 = rs.to_tree.children.select{|node| node.item.id == "_:p4"}[0]
    
    expected_rs_children = create_nodes [Xplain::Literal.new(15.0), Xplain::Literal.new(12.0), Xplain::Literal.new(10.0)]
    actual_rs_children = [p2.children[0], p3.children[0], p4.children[0]]
    
    assert_equal expected_rs_children, actual_rs_children
  end
  
  def test_count_computed_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
    input = Xplain::ResultSet.new(nil, input_nodes)
    computed_relation = input.to_tree.get_level_relation(1)
    rs = Map.new(input: input, level: 1, mapping_relation: Mapping::Count.new()).execute()
    assert_equal 1, rs.to_tree.children.size
    assert_equal create_nodes([Xplain::Literal.new(3)]), rs.to_tree.children
    
  end
  
  # def test_sum_with_restriction
  #   input_nodes = [Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")]
  #   rs = @papers_server.sum(input_nodes, Xplain::SchemaRelation.new(id: "_:relevance"), [Xplain::Literal.new(20), Xplain::Literal.new(8), Xplain::Literal.new(15)])
  #
  #   assert_equal Set.new([Xplain::Literal.new(15), Xplain::Literal.new(24), Xplain::Literal.new(20)]), Set.new(rs.map{|n| n.children}.flatten.map{|i|i.item})
  #
  #   rs.map!{|node| node.children}.flatten!
  #   assert_equal Set.new([rs[0].parent.item, rs[1].parent.item, rs[2].parent.item]), Set.new([Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3")])
  #
  # end
end