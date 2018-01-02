
require './test/xplain_unit_test'
require './filters/filter_factory'
require './operations/refine'
require './operations/pivot'
require './operations/filters/filter'
require './operations/filters/simple_filter'
require './operations/filters/composite_filter'
require './operations/filters/and'
require './operations/filters/or'
require './operations/filters/equals'
require './operations/filters/equals_one'
require './operations/filters/contains'
require './operations/filters/match'
require './operations/filters/greater_than'
require './operations/filters/greater_than_equal'
require './operations/filters/less_than_equal'
require './operations/filters/less_than'
require './operations/filters/not'
require './adapters/rdf/filter_interpreter'


class RefineTest < XplainUnitTest
  
  def test_filter_empty_input
    input_nodes = []
    root = Node.new("root")
    root.children = input_nodes
    actual_results = Refine.new(input: root, server: @papers_server) do
      equals do
        relation "_:cite"
        entity "_:p2"
      end
    end.execute()
    assert_true actual_results.children.empty?, actual_results.children.inspect
  end
  
  def test_filter_nil_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    root = Node.new("root")
    root.children = input_nodes
    begin
      actual_results = Refine.new(input: root, server: @papers_server) do
        equals do
          entity "_:p2"
        end
      end.execute()
    rescue MissingRelationException => e
      assert true
      return
    end
    assert false
  end

  def test_filter_empty_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    root = Node.new("root")
    root.children = input_nodes
    begin
      actual_results = Refine.new(input: root, server: @papers_server) do
        equals do
          relation nil
          entity "_:p2"
        end
      end.execute()
    rescue MissingRelationException => e
      assert true
      return
    end
    assert false
  end
  
  def test_filter_absent_value
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    root = Node.new("root")
    root.children = input_nodes
    begin
      actual_results = Refine.new(input: root, server: @papers_server) do
        equals do
          relation "_:cite"
        end
      end.execute()
    rescue MissingValueException => e
      assert true
      return
    end
    assert false
  end

  def test_filter_empty_value
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    root = Node.new("root")
    root.children = input_nodes
    begin
      actual_results = Refine.new(input: root, server: @papers_server) do
        equals do
          relation "_:cite"
          entity nil
        end
      end.execute()
    rescue MissingValueException => e
      assert true
      return
    end
    assert false
    
  end
  
  def test_and_less_than_2
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    
    root = Node.new("root")
    root.children = input_nodes
    actual_results = Refine.new(input: root, server: @papers_server) do
      And do[
        equals do
          relation "_:cite"
          entity "_:p2"
        end
      ]
      end
    end.execute()
    assert_equal [Xplain::Entity.new("_:paper1")], actual_results.children.map{|n|n.item}
    
  end
  
  def test_or_less_than_2
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    
    root = Node.new("root")
    root.children = input_nodes
    actual_results = Refine.new(input: root, server: @papers_server) do
      Or do[
        equals do
          relation "_:cite"
          entity "_:p2"
        end
      ]
      end
    end.execute()
    assert_equal [Xplain::Entity.new("_:paper1")], actual_results.children.map{|n|n.item}
    
  end
  
  def test_refine_equal
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3")),
      Node.new(Xplain::Entity.new("_:p4")),
      Node.new(Xplain::Entity.new("_:p5"))
    ]
    root = Node.new("root")
    root.children = input_nodes
    expected_results = Set.new([Xplain::Entity.new("_:paper1")])

    actual_results = Refine.new(input: root, server: @papers_server) do
      equals do
        relation "_:cite"
        entity "_:p2"
      end
    end.execute()
    
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
  
  
  def test_refine_equal_literal
    input_nodes = [
      Node.new(Xplain::Entity.new("_:journal1")),
      Node.new(Xplain::Entity.new("_:journal2")),
    ]
    root = Node.new("root")
    root.children = input_nodes
    expected_results = Set.new([Xplain::Entity.new("_:journal1")])

    actual_results = Refine.new(input: root, server: @papers_server) do
      equals do
        relation "_:releaseYear"
        literal "2005"
      end
    end.execute()
    
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end

  def test_refine_equal_literal_OR_same_relation
    input_nodes = [
      Node.new(Xplain::Entity.new("_:journal1")),
      Node.new(Xplain::Entity.new("_:journal2")),
    ]
    root = Node.new("root")
    root.children = input_nodes
    expected_results = Set.new([Xplain::Entity.new("_:journal1"), Xplain::Entity.new("_:journal2")])

    actual_results = Refine.new(input: root, server: @papers_server) do
      Or do [
        equals do
          relation "_:releaseYear"
          literal "2005"
        end,
        equals do
          relation "_:releaseYear"
          literal "2010"
        end
      ]
      end
    end.execute()
    
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
  
  def test_filter_equal_literal_OR_different_relation
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    root = Node.new("root")
    root.children = input_nodes
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p5")
    ]
    actual_results = Refine.new(input: root, server: @papers_server) do
      Or do [
        equals do
          relation "_:cite"
          entity "_:p2"
        end,
        equals do
          relation "_:author"
          entity "_:a1"
        end
      ]
      end
    end.execute()
    assert_false actual_results.children.empty?
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(actual_results.children.map{|n|n.item})
  end
  

  def test_refine_equal_literal_AND_same_relation
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3")),
      Node.new(Xplain::Entity.new("_:p4")),
      Node.new(Xplain::Entity.new("_:p5")),
      Node.new(Xplain::Entity.new("_:p6"))
    ]
    root = Node.new("root")
    root.children = input_nodes
    expected_results = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p5")])
    actual_results = Refine.new(input: root, server: @papers_server) do
      And do
        [
          equals do
            relation "_:author"
            entity "_:a1"
          end,
          equals do
            relation "_:author"
            entity "_:a2"
          end
        ]
      end
    end.execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
  
  def test_refine_property_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3")),
      Node.new(Xplain::Entity.new("_:p4")),
      Node.new(Xplain::Entity.new("_:p5")),
      Node.new(Xplain::Entity.new("_:p6")),
      Node.new(Xplain::Entity.new("_:p8"))
    ]
    root = Node.new("root")
    root.children = input_nodes
    expected_results = Set.new([Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p8")])
    actual_results = Refine.new(input: root, server: @papers_server) do
      And do [
        equals do
          relation "_:cite", "_:author"
          entity "_:a1"
        end,
        equals do
          relation "_:cite", "_:author"
          entity "_:a2"
        end
      ]
      end
    end.execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
  
  def test_refine_inverse_property_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:a1")),
      Node.new(Xplain::Entity.new("_:a2")),
      Node.new(Xplain::Entity.new("_:a3")),
      Node.new(Xplain::Entity.new("_:a4")),
    ]
    root = Node.new("root")
    root.children = input_nodes
    expected_results = Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")])
    actual_results = Refine.new(input: root, server: @papers_server) do 
      equals do
        relation inverse("_:author"), inverse("_:cite")
        entity "_:p10"
      end
    end.execute()
    assert_false actual_results.children.empty?
    assert_equal expected_results, Set.new(actual_results.children.map{|node| node.item})
  end
  
end