require 'forwardable'
require "test/unit"
require 'linkeddata'
require 'pry'
require './mixins/config'
require './mixins/operation_factory'
require './mixins/writable.rb'
require './mixins/readable.rb'
require './execution/workflow.rb'

require './mixins/enumerable'
require './mixins/relation'
require './exceptions/missing_relation_exception'
require './exceptions/missing_argument_exception'
require './exceptions/missing_value_exception'
require './exceptions/invalid_input_exception'
require './exceptions/disconnected_operation_exception'
require './exceptions/missing_auxiliary_function_exception'
require './exceptions/numeric_item_required_exception'

require './mixins/graph_converter'
require './model/node'
require './model/edge'
require './model/entity'
require './model/type'
require './model/literal'
require './model/schema_relation'
require './model/computed_relation'
require './model/path_relation'
require './model/namespace'
require './model/result_set'
require './model/relation_handler'

require './mixins/model_factory'

require './adapters/navigational'
require './adapters/searchable'
require './adapters/data_server'

require './adapters/rdf/rdf_navigational'
require './adapters/rdf/sparql_helper'
require './adapters/rdf/rdf_data_server'
require './visualization/visualization'
require 'securerandom'
require './operations/auxiliary_function'
require './operations/operation'
require './operations/set_operation'


class InputProxy
  attr_accessor :input_nodes
  def initialize(input_nodes = [])
    @input_nodes = input_nodes
  end
  
  def get_level(level)
    if(level == 1)
      root = Node.new("rootProxy")
      root.children = @input_nodes
      return [root]
    elsif(level == 2)
      return @input_nodes
    elsif(level == 3)
      return @input_nodes.map{|n|n.children}.flatten
    end
  end
  
  def count_levels
    nodes = @input_nodes || []
    count = 1
    while !nodes.empty?
      count += 1
      nodes = nodes.map{|node| node.children}.flatten
    end
    return count
  end
  
  def empty?
    @input_nodes.empty?
  end
  
  def copy
    InputProxy.new(@input_nodes.dup)
  end
  
  def leaves()
    @input_nodes
  end
end

class XplainUnitTest < Test::Unit::TestCase
  def setup
    load_papers_server
    load_simple_server
  end

  def load_papers_server
    papers_graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p4")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("http://xplain/cites"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("http://xplain/cites"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("http://xplain/cites"), RDF::URI("_:p4")]      
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p7"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p7"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p8"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p8"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p9"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p10"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      
      graph << [RDF::URI("_:p9"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI("_:type1")]
      graph << [RDF::URI("_:p10"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), RDF::URI("_:type2")]

      graph << [RDF::URI("_:paper1"),  RDF::URI("_:submittedTo"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a1") ]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a2") ]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p20"),  RDF::URI("_:author"), RDF::URI("_:a3")]

      graph << [RDF::URI("_:p2"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal2")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), RDF::Literal.new("2005", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), RDF::Literal.new("2010", datatype: RDF::XSD.string)]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2000", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), RDF::Literal.new("1998", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), RDF::Literal.new("2010", datatype: RDF::XSD.string)]     
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:relevance"), RDF::Literal.new(10, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:relevance"), RDF::Literal.new(20, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:relevance"), RDF::Literal.new(8, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:relevance"), RDF::Literal.new(16, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:relevance"), RDF::Literal.new(5, datatype: RDF::XSD.int)]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:relevance"), RDF::Literal.new(15, datatype: RDF::XSD.int)]
    
      graph << [RDF::URI("_:paper1"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("paper1_keyword", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:paper1"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("common_keyword", datatype: RDF::XSD.string)]
            
      graph << [RDF::URI("_:p2"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("paper2_keyword1 middle paper2_keyword2", datatype: RDF::XSD.string)]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("common_keyword", datatype: RDF::XSD.string)]      
      
      graph << [RDF::URI("_:p3"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("paper3_keyword", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p3"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("common_keyword", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:alternative_label_property"), RDF::Literal.new("common_keyword middle paper3_keyword2 end", datatype: RDF::XSD.string)]
      
      graph << [RDF::URI("_:p4"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("paper4_keyword", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p4"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("common_keyword", datatype: RDF::XSD.string)]
      
      graph << [RDF::URI("_:p5"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("paper5_keyword", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p5"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("common_keyword", datatype: RDF::XSD.string)]
      
      graph << [RDF::URI("_:p6"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("paper6_keyword", datatype: RDF::XSD.string)]
      graph << [RDF::URI("_:p6"),  RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#label"), RDF::Literal.new("common_keyword", datatype: RDF::XSD.string)]
           
           
      
    end

    @papers_server = RDFDataServer.new graph: papers_graph
    Xplain.set_default_server class: RDFDataServer, graph: papers_graph
  end
  
  def load_simple_server
    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r2"), RDF::URI("_:o2")]
      
      graph << [RDF::URI("_:p1"),  RDF::RDFS.label, RDF::Literal('lp1')]
      graph << [RDF::URI("_:p2"),  RDF::RDFS.label, RDF::Literal('lp2')]
      graph << [RDF::URI("_:r1"),  RDF::RDFS.label, RDF::Literal('lr1')]
      graph << [RDF::URI("_:r2"),  RDF::RDFS.label, RDF::Literal('lr2')]
      graph << [RDF::URI("_:o1"),  RDF::RDFS.label, RDF::Literal('lo1')]
      graph << [RDF::URI("_:o2"),  RDF::RDFS.label, RDF::Literal('lo2')]
    end

    @server = RDFDataServer.new graph: @graph
  end
  
  def create_nodes(items)
    items.map{|item| Node.new(item)}
  end
  
  def assert_same_items(node_list1, node_list2)
    
    assert_equal node_list1.class, node_list2.class
    
    items_list1 = node_list1.to_a.compact.map{|node| node.item if node.is_a? Node}
    items_list2 = node_list2.to_a.compact.map{|node| node.item if node.is_a? Node}
    
    nodes_list_class = node_list1.class
    assert_equal nodes_list_class.new(items_list1), nodes_list_class.new(items_list2)    
  end
  
  def assert_same_items_set(node_list1, node_list2)
    assert_same_items(Set.new(node_list1.to_a), Set.new(node_list2.to_a))
  end
  
  def assert_same_items_tree_set(root1, root2)
    
    item1 = root1.item if root1.is_a? Node
    item2 = root2.item if root2.is_a? Node
    assert_equal item1, item2
    assert_same_items_set root1.children, root2.children
    for child_root1 in root1.children
       child_root2 = root2.children.select{|node| node.item == child_root1.item}.first
       assert_same_items_tree_set(child_root1, child_root2)
    end
  end
  
  def assert_same_items_tree_set_no_root(root1, root2)
    for child_root1 in root1.children
       child_root2 = root2.children.select{|node| node.item == child_root1.item}.first
       assert_same_items_tree_set(child_root1, child_root2)
    end
  end
  
  alias assert_same_result_set assert_same_items_tree_set_no_root  

  def test_assert_same_items_1_level
    i1p1 = Node.new(Xplain::Entity.new("_:p1"))
    i1p2 = Node.new(Xplain::Entity.new("_:p2"))
    input1 = Xplain::ResultSet.new("_:rs", [i1p1, i1p2])

    i2p1 = Node.new(Xplain::Entity.new("_:p1"))
    i2p2 = Node.new(Xplain::Entity.new("_:p2"))
    i2p3 = Node.new(Xplain::Entity.new("_:p3"))    
    input2 = Xplain::ResultSet.new("_:rs", [i2p1, i2p2, i2p3])

    i3p1 = Node.new(Xplain::Entity.new("_:p1"))
    i3p2 = Node.new(Xplain::Entity.new("_:p2"))
    input3 = Xplain::ResultSet.new("_:rs2", [i3p1, i3p2])
    
    
    assert_nothing_raised(Test::Unit::AssertionFailedError) {  assert_same_result_set(input1.to_tree, input3.to_tree)}
    assert_nothing_raised(Test::Unit::AssertionFailedError) {  assert_same_result_set(input2.to_tree, input2.to_tree)}
    assert_raise(Test::Unit::AssertionFailedError) {assert_same_result_set(input2.to_tree, input1.to_tree)}
    assert_raise(Test::Unit::AssertionFailedError) {assert_same_result_set(input2.to_tree, input3.to_tree)}
  end

  def test_assert_same_items_2_levels
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

    i3p1 = Node.new(Xplain::Entity.new("_:p1"))
    i3p2 = Node.new(Xplain::Entity.new("_:p2"))
    i3p1.children = [Node.new(Xplain::Entity.new("_:p1.1")), Node.new(Xplain::Entity.new("_:p1.2"))]
    i3p2.children = [Node.new(Xplain::Entity.new("_:p2.1")), Node.new(Xplain::Entity.new("_:p2.2"))]
    input3 = Xplain::ResultSet.new(nil, [i3p1, i3p2])
    
    
    assert_nothing_raised(Test::Unit::AssertionFailedError) {  assert_same_result_set(input1.to_tree, input3.to_tree)}
    assert_nothing_raised(Test::Unit::AssertionFailedError) {  assert_same_result_set(input2.to_tree, input2.to_tree)}
    assert_raise(Test::Unit::AssertionFailedError) {assert_same_result_set(input2.to_tree, input1.to_tree)}
    assert_raise(Test::Unit::AssertionFailedError) {assert_same_result_set(input2.to_tree, input3.to_tree)}
  end
  
  def test_assert_same_items_different_levels
    i1p1 = Node.new(Xplain::Entity.new("_:p1"))
    i1p2 = Node.new(Xplain::Entity.new("_:p2"))
    i1p1.children = [Node.new(Xplain::Entity.new("_:p1.1"))]    
    input1 = Xplain::ResultSet.new(nil, [i1p1, i1p2])

    i2p1 = Node.new(Xplain::Entity.new("_:p1"))
    i2p2 = Node.new(Xplain::Entity.new("_:p2"))
    input2 = Xplain::ResultSet.new(nil, [i2p1, i2p2])

    i3p1 = Node.new(Xplain::Entity.new("_:p1"))
    i3p2 = Node.new(Xplain::Entity.new("_:p2"))
    i3p1.children = [Node.new(Xplain::Entity.new("_:p1.1"))]
    input3 = Xplain::ResultSet.new(nil, [i3p1, i3p2])
    
    
    assert_nothing_raised(Test::Unit::AssertionFailedError) {  assert_same_result_set(input1.to_tree, input3.to_tree)}
    assert_nothing_raised(Test::Unit::AssertionFailedError) {  assert_same_result_set(input2.to_tree, input2.to_tree)}
    assert_raise(Test::Unit::AssertionFailedError) {assert_same_result_set(input2.to_tree, input1.to_tree)}
    assert_raise(Test::Unit::AssertionFailedError) {assert_same_result_set(input2.to_tree, input3.to_tree)}
  end

end
