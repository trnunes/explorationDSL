require './test/xplain_unit_test'
require './operations/filter/filter_factory'

require './operations/filter/generic_filter'
require './operations/filter/relation_filter'
require './operations/filter/composite_filter'


class CompositionsTest < XplainUnitTest
  
  def test_inexistent_auxiliary_function    
    base_op = Xplain::KeywordSearch.new
    
    assert_raise NameError do
      op = base_op.refine() do
        equals do
          relation "_:author"
          entity "_:p2"
        end
      end.pivot(){inexistent_aux_function "_:author"}.execute()
    end
  end
  
  def test_chain_two_operations
    
    op = Xplain::Refine.new do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end.pivot(){relation "_:author"}
    
    assert_false op.nil?
    assert_equal Xplain::Pivot, op.class
    
    refine_op = op.inputs.first
    assert_false refine_op.nil?
    assert_equal Xplain::Refine, refine_op.class
  end

  def test_chain_two_operations_executing_last_one
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
     
     expected_results = Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p5")])
     
     op = Xplain::Pivot.new(inputs: root){relation "_:cite"}.refine do
         equals do
           relation "_:author"
           entity "_:a1"
         end
     end
     
      rs = op.execute
      assert_false rs.to_tree.children.empty?
      assert_equal expected_results, Set.new(rs.to_tree.children.map{|node| node.item})
  
  end
  
  def test_chain_intersect

    ref = Xplain::Refine.new(inputs: Node.new('root')) do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end
    pivot = Xplain::Pivot.new(inputs: Node.new('root')){relation "_:author"}
    intersect = pivot.intersect ref
    
    
    assert_equal Set.new([pivot, ref]), Set.new(intersect.inputs)
    
  end
  
  def test_chain_unite

    ref = Xplain::Refine.new(inputs: Node.new('root')) do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end
    pivot = Xplain::Pivot.new(inputs: Node.new('root')){relation "_:author"}
    unite = pivot.unite ref
    assert_equal Set.new([pivot, ref]), Set.new(unite.inputs)    
  end
  
  def test_chain_diff
    ref = Xplain::Refine.new(inputs: Node.new('root')) do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end
    pivot = Xplain::Pivot.new(inputs: Node.new('root')){relation "_:author"}
    diff = pivot.diff ref
    assert_equal Set.new([pivot, ref]), Set.new(diff.inputs)
  end
  
  def test_pivot_refine
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
    
    expected_results = Set.new([Xplain::Entity.new("_:p5")])
    
    op = Xplain::Pivot.new(inputs: root){relation "_:cite"}.refine do
      And do [
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
    end
    assert_equal expected_results, Set.new(op.execute.to_tree.children.map{|n|n.item})
   end
   
   def test_pivot_refine_intersect
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
     
     expected_results = Set.new([Xplain::Entity.new("_:p5")])
     op = Xplain::Pivot.new(inputs: root){relation "_:cite"}.refine do
         equals do
           relation "_:author"
           entity "_:a1"
         end
     end.intersect( 
       Xplain::Pivot.new(inputs: root){relation "_:cite"}.refine do
         equals do
           relation "_:author"
           entity "_:a2"
         end
       end
      )
    
      rs = op.execute
      assert_false rs.to_tree.children.empty?
      assert_equal expected_results, Set.new(rs.to_tree.children.map{|node| node.item})
     
   end
   
   def test_pivot_refine_unite
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
     
     expected_results = Set.new([Xplain::Entity.new("_:p2"), Xplain::Entity.new("_:p3"), Xplain::Entity.new("_:p5")])
     op = Xplain::Pivot.new(inputs: root){relation "_:cite"}.refine do
         equals do
           relation "_:author"
           entity "_:a1"
         end
     end.unite( 
       Xplain::Pivot.new(inputs: root){relation "_:cite"}.refine do
         equals do
           relation "_:author"
           entity "_:a2"
         end
       end
      )
    
      rs = op.execute
      assert_false rs.to_tree.children.empty?
      assert_equal expected_results, Set.new(rs.to_tree.children.map{|node| node.item})
     
   end
   
   def test_pivot_refine_diff
   end
  
end