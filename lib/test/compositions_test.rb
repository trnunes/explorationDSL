require './test/xplain_unit_test'
require './operations/filters/filter_factory'
require './operations/refine'
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
require './operations/pivot'
require './operations/group'
require './operations/pivot'
require './operations/map'
require './operations/intersect'
require './operations/unite'
require './operations/diff'
require './operations/keyword_search'

class CompositionsTest < XplainUnitTest
  
  def test_inexistent_auxiliary_function    
    base_op = KeywordSearch.new
    
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
    
    op = Refine.new do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end.pivot(){relation "_:author"}
    
    assert_false op.nil?
    assert_equal Pivot, op.class
    
    refine_op = op.inputs.first
    assert_false refine_op.nil?
    assert_equal Refine, refine_op.class
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
     
     op = Pivot.new(root){relation "_:cite"}.refine do
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
    
    ref = Refine.new(Node.new('root')) do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end
    pivot = Pivot.new(Node.new('root')){relation "_:author"}
    intersect = pivot.intersect ref
    
    
    assert_equal Set.new([pivot, ref]), Set.new(intersect.inputs)
    
  end
  
  def test_chain_unite
    
    ref = Refine.new(Node.new('root')) do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end
    pivot = Pivot.new(Node.new('root')){relation "_:author"}
    unite = pivot.unite ref
    assert_equal Set.new([pivot, ref]), Set.new(unite.inputs)    
  end
  
  def test_chain_diff
    
    ref = Refine.new(Node.new('root')) do
      equals do
        relation "_:author"
        entity "_:p2"
      end
    end
    pivot = Pivot.new(Node.new('root')){relation "_:author"}
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
    
    op = Pivot.new(root){relation "_:cite"}.refine do
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
     op = Pivot.new(root){relation "_:cite"}.refine do
         equals do
           relation "_:author"
           entity "_:a1"
         end
     end.intersect( 
       Pivot.new(root){relation "_:cite"}.refine do
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
     op = Pivot.new(root){relation "_:cite"}.refine do
         equals do
           relation "_:author"
           entity "_:a1"
         end
     end.unite( 
       Pivot.new(root){relation "_:cite"}.refine do
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