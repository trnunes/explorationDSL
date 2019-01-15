
require './test/xplain_unit_test'
require './operations/filter/filter_factory'
require './operations/filter/generic_filter'
require './operations/filter/relation_filter'
require './operations/filter/composite_filter'

require './operations/filter/in_memory_filter_interpreter'



class Xplain::RefineTest < XplainUnitTest
  
  def test_filter_empty_input
    input_nodes = []
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    actual_results = Xplain::Refine.new(inputs: root) do
      equals do
        relation "_:cite"
        entity "_:p2"
      end
    end.execute()
    assert_true actual_results.to_tree.children.empty?, actual_results.to_tree.children.inspect
  end
  
  def test_filter_nil_relation
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    begin
      actual_results = Xplain::Refine.new(inputs: root) do
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
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    begin
      actual_results = Xplain::Refine.new(inputs: root) do
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
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    begin
      actual_results = Xplain::Refine.new(inputs: root) do
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
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    begin
      actual_results = Xplain::Refine.new(inputs: root) do
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
    
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    actual_results = Xplain::Refine.new(inputs: root) do
      And do[
        equals do
          relation "_:cite"
          entity "_:p2"
        end
      ]
      end
    end.execute()
    assert_equal [Xplain::Entity.new("_:paper1")], actual_results.to_tree.children.map{|n|n.item}
    
  end
  
  def test_or_less_than_2
    input_nodes = create_nodes [Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), Xplain::Entity.new("_:p5")]
    
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    actual_results = Xplain::Refine.new(inputs: root) do
      Or do[
        equals do
          relation "_:cite"
          entity "_:p2"
        end
      ]
      end
    end.execute()
    assert_equal [Xplain::Entity.new("_:paper1")], actual_results.to_tree.children.map{|n|n.item}
    
  end
  
  def test_refine_equal
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3")),
      Node.new(Xplain::Entity.new("_:p4")),
      Node.new(Xplain::Entity.new("_:p5"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:paper1")])

    actual_results = Xplain::Refine.new(inputs: root) do
      equals do
        relation "_:cite"
        entity "_:p2"
      end
    end.execute()
    
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end
  
  
  def test_refine_equal_literal
    input_nodes = [
      Node.new(Xplain::Entity.new("_:journal1")),
      Node.new(Xplain::Entity.new("_:journal2")),
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:journal1")])

    actual_results = Xplain::Refine.new(inputs: root) do
      equals do
        relation "_:releaseYear"
        literal "2005"
      end
    end.execute()
    
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end

  def test_refine_equal_literal_OR_same_relation
    input_nodes = [
      Node.new(Xplain::Entity.new("_:journal1")),
      Node.new(Xplain::Entity.new("_:journal2")),
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:journal1"), Xplain::Entity.new("_:journal2")])

    actual_results = Xplain::Refine.new(inputs: root) do
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
    
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end
  
  def test_filter_equal_literal_OR_different_relation
    input_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p2"), 
      Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4"), 
      Xplain::Entity.new("_:p5"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p7"), Xplain::Entity.new("_:p8"),
      Xplain::Entity.new("_:p9"), Xplain::Entity.new("_:p10")
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_output_nodes = create_nodes [
      Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), 
      Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p5")
    ]
    actual_results = Xplain::Refine.new(inputs: root) do
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
    assert_false actual_results.to_tree.children.empty?
    assert_equal Set.new(expected_output_nodes.map{|n| n.item}), Set.new(actual_results.to_tree.children.map{|n|n.item})
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
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p5")])
    actual_results = Xplain::Refine.new(inputs: root) do
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
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
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
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:paper1"), Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p8")])
    actual_results = Xplain::Refine.new(inputs: root) do
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
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end
  
  def test_refine_property_path_size3
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3")),
      Node.new(Xplain::Entity.new("_:p4")),
      Node.new(Xplain::Entity.new("_:p5")),
      Node.new(Xplain::Entity.new("_:p6")),
      Node.new(Xplain::Entity.new("_:p8"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p4")])
    actual_results = Xplain::Refine.new(inputs: root) do
      equals do
        relation inverse("_:cite"), "_:submittedTo", "_:releaseYear"
        literal "2005"
      end
    end.execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end

  
  def test_refine_inverse_property_path
    input_nodes = [
      Node.new(Xplain::Entity.new("_:a1")),
      Node.new(Xplain::Entity.new("_:a2")),
      Node.new(Xplain::Entity.new("_:a3")),
      Node.new(Xplain::Entity.new("_:a4")),
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:a1"), Xplain::Entity.new("_:a2")])
    actual_results = Xplain::Refine.new(inputs: root) do 
      equals do
        relation inverse("_:author"), inverse("_:cite")
        entity "_:p10"
      end
    end.execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end  
  
  def test_refine_custom_filter_select
    input_nodes = [
      Node.new(Xplain::Entity.new("_:a1")),
      Node.new(Xplain::Entity.new("_:a2")),
      Node.new(Xplain::Entity.new("_:a3")),
      Node.new(Xplain::Entity.new("_:a4")),
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:a1")])
    actual_results = Xplain::Refine.new(inputs: root) do
      c_filter "|e| e.item.id == \"_:a1\""
    end.execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end
  
  def test_refine_named_cfilter_select
    input_nodes = [
      Node.new(Xplain::Entity.new("_:a1")),
      Node.new(Xplain::Entity.new("_:a2")),
      Node.new(Xplain::Entity.new("_:a3")),
      Node.new(Xplain::Entity.new("_:a4")),
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:a1")])
    actual_results = Xplain::Refine.new(inputs: root) do
      c_filter name: :by_id, code: "|e| e.item.id == \"_:a1\""
    end.execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end

  def test_refine_named_cfilter_select_AND
    input_nodes = [
      Node.new(Xplain::Entity.new("_:a1")),
      Node.new(Xplain::Entity.new("_:a2")),
      Node.new(Xplain::Entity.new("_:a3")),
      Node.new(Xplain::Entity.new("_:a4")),
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:a1")])
    actual_results = Xplain::Refine.new(inputs: root) do 
      And do 
        [
          c_filter(name: :by_id, code: '|e| e.item.text.include? "a1"')
        ]
      end
    end.execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})
  end

  def test_refine_named_cfilter_select_AND_dataset_filter
    input_nodes = [
      Node.new(Xplain::Entity.new("_:paper1")),
      Node.new(Xplain::Entity.new("_:p2")),
      Node.new(Xplain::Entity.new("_:p3")),
      Node.new(Xplain::Entity.new("_:p4")),
      Node.new(Xplain::Entity.new("_:p5")),
      Node.new(Xplain::Entity.new("_:p6")),
      Node.new(Xplain::Entity.new("_:p8"))
    ]
    root = Xplain::ResultSet.new(nil, input_nodes)
    
    expected_results = Set.new([Xplain::Entity.new("_:p6"), Xplain::Entity.new("_:p8")])
    actual_results = Xplain::Refine.new(inputs: root) do
      And do [
        equals do
          relation "_:cite", "_:author"
          entity "_:a1"
        end,
        c_filter(name: :by_id, code: '|e| e.item.text.include?("p6") || e.item.text.include?("p8")')
      ]
      end
    end.execute()
    assert_false actual_results.to_tree.children.empty?
    assert_equal expected_results, Set.new(actual_results.to_tree.children.map{|node| node.item})

  end
  
  def test_refine_level_2_set

    paper1 = Node.new(Xplain::Entity.new("_:paper1"))
    p2 = Node.new(Xplain::Entity.new("_:p2"))
    p3 = Node.new(Xplain::Entity.new("_:p3"))
    p4 = Node.new(Xplain::Entity.new("_:p4"))
    
    journal1 = Node.new(Xplain::Entity.new("_:journal1"))
    journal2 = Node.new(Xplain::Entity.new("_:journal2"))
    
    journal1.children = [paper1, p2]
    journal2.children = [p3, p4]
    
    input = Xplain::ResultSet.new(nil, [journal1, journal2])
    
    expected_journal1 = Node.new(Xplain::Entity.new("_:journal1"))
    expected_journal1.children = [Node.new(Xplain::Entity.new("_:paper1")), Node.new(Xplain::Entity.new("_:p2"))]
    expected_results1 = Xplain::ResultSet.new(nil, [expected_journal1])
    
    expected_journal2 = Node.new(Xplain::Entity.new("_:journal2"))
    expected_journal2.children = [Node.new(Xplain::Entity.new("_:p3")), Node.new(Xplain::Entity.new("_:p4"))]    
    expected_results2 = Xplain::ResultSet.new(nil, [expected_journal2])
    
    actual_results = Xplain::Refine.new(inputs: input, level: 2) do
      equals do
        relation "_:releaseYear"
        literal "2005"
      end
    end.execute()
    actual_results.title = expected_results1.title
    assert_same_result_set actual_results, expected_results1

    actual_results = Xplain::Refine.new(inputs: input, level: 2) do
      equals do
        relation "_:releaseYear"
        literal "2010"
      end
    end.execute()
    actual_results.title = expected_results2.title
    assert_same_result_set actual_results, expected_results2
  end

  def test_refine_level_3_set

    paper1 = Node.new(Xplain::Entity.new("_:paper1"))
    p2 = Node.new(Xplain::Entity.new("_:p2"))
    p3 = Node.new(Xplain::Entity.new("_:p3"))
    p4 = Node.new(Xplain::Entity.new("_:p4"))
    
    journal1 = Node.new(Xplain::Entity.new("_:journal1"))
    journal2 = Node.new(Xplain::Entity.new("_:journal2"))
    
    journal1.children = [paper1, p2]
    journal2.children = [p3, p4]

    input = Xplain::ResultSet.new("test_set", [journal1, journal2])
    
    expected_journal1 = Node.new(Xplain::Entity.new("_:journal1"))
    expected_journal1.children = [Node.new(Xplain::Entity.new("_:paper1")), Node.new(Xplain::Entity.new("_:p2"))]
    
    expected_journal2 = Node.new(Xplain::Entity.new("_:journal2"))
    expected_journal2.children = [Node.new(Xplain::Entity.new("_:p3"))]
    
    expected_results1 = Xplain::ResultSet.new("test_set", [expected_journal1])
    expected_results2 = Xplain::ResultSet.new("test_set", [expected_journal2])
    
    actual_results = Xplain::Refine.new(inputs: input, level: 3) do
      equals do
        relation "_:author"
        entity "_:a1"
      end
    end.execute()
    assert_same_result_set expected_results1, actual_results

    actual_results = Xplain::Refine.new(inputs: input, level: 3) do
      equals do
        relation "_:publishedOn"
        entity "_:journal2"
      end
    end.execute()

    assert_same_result_set expected_results2, actual_results
  end
  
  def test_refine_level_3_set_repeated_children

    paper1 = Node.new(Xplain::Entity.new("_:paper1"))
    p2 = Node.new(Xplain::Entity.new("_:p2"))
    p3 = Node.new(Xplain::Entity.new("_:p3"))
    p4 = Node.new(Xplain::Entity.new("_:p4"))
    
    journal1 = Node.new(Xplain::Entity.new("_:journal1"))
    journal2 = Node.new(Xplain::Entity.new("_:journal2"))
    
    p3_j1 = Node.new(Xplain::Entity.new("_:p3"))
    journal1.children = [paper1, p2, p3_j1]
    journal2.children = [p3, p4]

    input = Xplain::ResultSet.new("test_set", [journal1, journal2])
    
    expected_journal1 = Node.new(Xplain::Entity.new("_:journal1"))
    expected_journal1.children = [Node.new(Xplain::Entity.new("_:p3"))]
    
    expected_journal2 = Node.new(Xplain::Entity.new("_:journal2"))
    expected_journal2.children = [Node.new(Xplain::Entity.new("_:p3"))]
    
    
    expected_results = Xplain::ResultSet.new("test_set", [expected_journal2, expected_journal1])

    actual_results = Xplain::Refine.new(inputs: input, level: 3) do
      equals do
        relation "_:publishedOn"
        entity "_:journal2"
      end
    end.execute()
    assert_same_result_set actual_results, expected_results
  end
end