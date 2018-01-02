require './test/xplain_unit_test'
require './operations/pivot'

class PivotTest < XplainUnitTest

  def test_empty_input_set
    input_nodes = []
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    
    actual_results = Pivot.new(input: root, server: @papers_server, relation: Xplain::SchemaRelation.new(id: "_:r1", server: @papers_server)).execute()
    assert_true actual_results.children.empty?
  end
  
  def test_empty_relation
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    
    begin
      actual_results = Pivot.new(input: root, server: @papers_server).execute()
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
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    

    actual_results = Pivot.new(input: root, server: @papers_server, relation: Xplain::SchemaRelation.new(id:"_:r1", server: @papers_server)).execute()
    assert_true actual_results.children.empty?
  end
  
  def test_pivot_single_relation
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p1")),
      Node.new(Xplain::Entity.new("_:p2"))
    ]
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    
    expected_results = Set.new([Xplain::Entity.new("_:o1"), Xplain::Entity.new("_:o2")])

    actual_results = Pivot.new(input: root, server: @server, relation: Xplain::SchemaRelation.new(id:"_:r1", server: @server)).execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
    
  end
  
  def test_pivot_single_relation_inverse
    input_nodes = [
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3"))
    ]
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    
    expected_results = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8")])

    actual_results = Pivot.new(input: root, server: @papers_server, relation: Xplain::SchemaRelation.new(id:"_:cite", inverse: true, server: @papers_server)).execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end

  def test_pivot_relation_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p6"))
    ]
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    expected_results = Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")])
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:cite"), Xplain::SchemaRelation.new(id: "_:author")], server: @papers_server)
    actual_results = Pivot.new(input: root, server: @papers_server, relation: path).execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
  
  
  def test_pivot_backward_relation_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:a1"))
    ]
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:author", inverse: true), Xplain::SchemaRelation.new(id: "_:cite", inverse: true)], server: @papers_server)
    expected_results = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"), Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")])

    actual_results = Pivot.new(input: root, server: @papers_server, relation: path).execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
    
  def test_pivot_forward_backward_relation_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:journal1"))
    ]
    root = Node.new(Xplain::Entity.new("root"))
    root.children = input_nodes
    
    expected_results = Set.new([Xplain::Entity.new("_:a1")])
    path = Xplain::PathRelation.new(relations: [Xplain::SchemaRelation.new(id: "_:publishedOn", inverse: true), Xplain::SchemaRelation.new(id: "_:author")], server: @papers_server)
    actual_results = Pivot.new(input: root, server: @papers_server, relation: path).execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
    
end