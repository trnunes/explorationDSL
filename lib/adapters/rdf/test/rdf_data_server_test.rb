require './test/xplain_unit_test'
require 'rdf'
require 'sparql/client'


class RDFDataServerTest < XplainUnitTest
  
  def setup
    super()
    @xplain_ns = "http://tecweb.inf.puc-rio.br/xplain/"
    @rdf_ns = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    @dcterms = "http://purl.org/dc/terms/"
    @sparql_client = SPARQL::Client.new @graph
    Xplain.set_exploration_repository @server
    Xplain.set_default_server @server
    
  end

  def get_triples_set(sparql_query)
    Set.new get_triples_array sparql_query
  end

  def get_triples_array(sparql_query)
    triples_found = []
    @sparql_client.query(sparql_query).each do |sol|
      triples_found << [sol[:s].to_s, sol[:p].to_s, sol[:o].to_s]
    end
    triples_found.sort{|t1, t2| t1.inspect <=> t2.inspect}
  end
  
  
  def test_save_resultset_flat
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]    
    
    rs = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes)
    rs.save()
    
    expected_triples = Set.new
    expected_triples << ["#{@xplain_ns}test_id", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "#{@xplain_ns}ResultSet"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}has_item", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}text_relation", "#{@xplain_ns}has_text"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}has_text", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}has_item", "_:p2"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}text_relation", "#{@xplain_ns}has_text"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}has_text", "_:p2"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"]
    
    sparql_query = "SELECT ?s ?p ?o WHERE{?s ?p ?o. values ?p{<#{@xplain_ns}included_in> <#{@xplain_ns}index>  <#{@xplain_ns}has_item> <#{@xplain_ns}text_relation> <#{@xplain_ns}has_text> <#{@rdf_ns}type>}.}"
    
    assert_equal expected_triples, get_triples_set(sparql_query)
  
    
  end

  def test_save_resultset_title_intention
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    resulted_from = Xplain::ResultSet.new(id: "resulted_from_set")
    operation = Xplain::KeywordSearch.new(inputs: [resulted_from], keyword_phrase:  'test_keyword')
    
    rs = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes, intention: operation, title: "title_set")
    
    rs.save()
    
    expected_triples = Set.new
    expected_triples << [ "#{@xplain_ns}test_id", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "#{@xplain_ns}ResultSet"]
    expected_triples << [ "#{@xplain_ns}test_id", "#{@xplain_ns}intention", "Xplain::ResultSet.load(\"resulted_from_set\").keyword_search(keyword_phrase: 'test_keyword')"]
    expected_triples << [ "#{@xplain_ns}test_id", "#{@dcterms}title", "title_set"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}text_relation", "#{@xplain_ns}has_text"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}has_text", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}has_item", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}text_relation", "#{@xplain_ns}has_text"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}has_text", "_:p2"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}has_item", "_:p2"]
    
    sparql_query = "SELECT ?s ?p ?o WHERE{?s ?p ?o. values ?p{<#{@xplain_ns}resulted_from> <#{@xplain_ns}included_in> <#{@xplain_ns}text_relation> <#{@xplain_ns}has_text> <#{@xplain_ns}index> <#{@xplain_ns}has_item> <#{@dcterms}title> <#{@xplain_ns}intention> <#{@rdf_ns}type>}.}" 
    
    assert_equal expected_triples, get_triples_set(sparql_query)
  
    
  end
  
  def test_save_resultset_two_levels
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    
    rs = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes)
    rs.save()
    
    expected_triples = []
    expected_triples << ["#{@xplain_ns}test_id", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "#{@xplain_ns}ResultSet"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}children", "#{@xplain_ns}np1.1"]
    expected_triples << [ "#{@xplain_ns}np1.1", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}children", "#{@xplain_ns}np1.2"]
    expected_triples << [ "#{@xplain_ns}np1.2", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np1.1", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np1.2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}has_item", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}has_item", "_:p2"]
    expected_triples << [ "#{@xplain_ns}np1.1", "#{@xplain_ns}has_item", "_:p1.1"]
    expected_triples << [ "#{@xplain_ns}np1.2", "#{@xplain_ns}has_item", "_:p1.2"]
    
    sparql_query = "SELECT ?s ?p ?o WHERE{?s ?p ?o. values ?p{<#{@xplain_ns}included_in> <#{@xplain_ns}index>  <#{@xplain_ns}has_item> <#{@xplain_ns}children> <#{@rdf_ns}type>}}"
    expected_triples.sort!{|t1, t2| t1.inspect <=> t2.inspect}
    assert_equal expected_triples, get_triples_array(sparql_query)
  end
  
  def test_save_same_item_two_rs_flat
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]

    input_nodes2 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1rs2"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2rs2")
    ]
    
    rs1 = Xplain::ResultSet.new(id: "test_id1", nodes: input_nodes)
    rs2 = Xplain::ResultSet.new(id: "test_id2", nodes: input_nodes2)
    rs1.save
    rs2.save
    
    expected_triples = []
    expected_triples << ["#{@xplain_ns}test_id1", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "#{@xplain_ns}ResultSet"]
    expected_triples << ["#{@xplain_ns}test_id2", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "#{@xplain_ns}ResultSet"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id2"]
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np2rs2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id2"]
    expected_triples << [ "#{@xplain_ns}np2rs2", "#{@xplain_ns}index", "2"]
    
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}has_item", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}has_item", "_:p2"]
    
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}has_item", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np2rs2", "#{@xplain_ns}has_item", "_:p2"]

    sparql_query = "SELECT ?s ?p ?o WHERE{?s ?p ?o. values ?p{<#{@xplain_ns}included_in> <#{@xplain_ns}index>  <#{@xplain_ns}has_item> <#{@xplain_ns}children> <#{@rdf_ns}type>}}"
    expected_triples.sort!{|t1, t2| t1.inspect <=> t2.inspect}

    assert_equal expected_triples, get_triples_array(sparql_query)
  end
  
  def test_save_same_item_two_rs_two_level
    input_nodes1 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes1.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    input_nodes2 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1rs2"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p3"), id: "np3")
    ]
    input_nodes2.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1rs2"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2rs2")]
    
    rs1 = Xplain::ResultSet.new(id: "test_id1", nodes: input_nodes1)
    rs2 = Xplain::ResultSet.new(id: "test_id2", nodes: input_nodes2)
    rs1.save
    rs2.save
    
    expected_triples = []
    expected_triples << ["#{@xplain_ns}test_id1", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "#{@xplain_ns}ResultSet"]
    expected_triples << ["#{@xplain_ns}test_id2", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "#{@xplain_ns}ResultSet"]

    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}children", "#{@xplain_ns}np1.1"]
    expected_triples << [ "#{@xplain_ns}np1.1", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np1.1", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id1"]
    expected_triples << [ "#{@xplain_ns}np1.2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id1"]
    expected_triples << [ "#{@xplain_ns}np1.2", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}children", "#{@xplain_ns}np1.2"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np1", "#{@xplain_ns}has_item", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np2", "#{@xplain_ns}has_item", "_:p2"]
    expected_triples << [ "#{@xplain_ns}np1.1", "#{@xplain_ns}has_item", "_:p1.1"]
    expected_triples << [ "#{@xplain_ns}np1.2", "#{@xplain_ns}has_item", "_:p1.2"]

    
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id2"]
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}children", "#{@xplain_ns}np1.1rs2"]
    expected_triples << [ "#{@xplain_ns}np1.1rs2", "#{@xplain_ns}index", "1"]
    expected_triples << [ "#{@xplain_ns}np1.1rs2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id2"]
    expected_triples << [ "#{@xplain_ns}np1.2rs2", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id2"]
    expected_triples << [ "#{@xplain_ns}np1.2rs2", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}children", "#{@xplain_ns}np1.2rs2"]
    expected_triples << [ "#{@xplain_ns}np3", "#{@xplain_ns}included_in", "#{@xplain_ns}test_id2"]
    expected_triples << [ "#{@xplain_ns}np3", "#{@xplain_ns}index", "2"]
    expected_triples << [ "#{@xplain_ns}np1rs2", "#{@xplain_ns}has_item", "_:p1"]
    expected_triples << [ "#{@xplain_ns}np3", "#{@xplain_ns}has_item", "_:p3"]
    expected_triples << [ "#{@xplain_ns}np1.1rs2", "#{@xplain_ns}has_item", "_:p1.1"]
    expected_triples << [ "#{@xplain_ns}np1.2rs2", "#{@xplain_ns}has_item", "_:p1.2"]
    
    sparql_query = "SELECT ?s ?p ?o WHERE{ ?s ?p ?o. values ?p{<#{@xplain_ns}included_in> <#{@xplain_ns}index> <#{@xplain_ns}has_item> <#{@xplain_ns}children> <#{@rdf_ns}type>}}"
    
    actual_rs = get_triples_array(sparql_query)
    expected_triples.sort!{|t1, t2| t1.inspect <=> t2.inspect}
    assert_equal expected_triples, actual_rs 
  end

  def test_load_flat_rs
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_rs = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes)
    input_rs.save()
    
    expected_rs = Xplain::ResultSet.load("test_id")
    
    assert_same_result_set input_rs, expected_rs
    

  end
  
  def test_load_flat_rs_intention
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    resulted_from = Xplain::ResultSet.new(id: "resulted_from_set", nodes: [Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "nprs1")])
    resulted_from.save
    operation = Xplain::KeywordSearch.new(inputs: [resulted_from], keyword_phrase:  'test_keyword')
    input_rs = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes, intention: operation, title: "title_set")
    input_rs.save()
    
    expected_rs = Xplain::ResultSet.load("test_id")
    
    assert_same_result_set input_rs, expected_rs
    dsl_parser = DSLParser.new
    assert_equal dsl_parser.to_ruby(expected_rs.intention), "Xplain::ResultSet.load(\"resulted_from_set\").keyword_search(keyword_phrase: 'test_keyword')"
    assert_same_result_set_no_title expected_rs.intention.inputs.first, resulted_from

  end

  def test_load_flat_two_rs
    input_nodes1 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    input_nodes2 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1rs2"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p3"), id: "np3")
    ]
    rs1 = Xplain::ResultSet.new(id: "test_id1", nodes: input_nodes1)
    rs2 = Xplain::ResultSet.new(id: "test_id2", nodes: input_nodes2)
    rs1.save
    rs2.save
    
    loaded_rs1 = Xplain::ResultSet.load("test_id1")
    loaded_rs2 = Xplain::ResultSet.load("test_id2")
    
    assert_same_result_set rs1, loaded_rs1
    assert_same_result_set rs2, loaded_rs2

  end
  
  def test_load_flat_rs_multilevel
    input_nodes1 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes1.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    
    rs1 = Xplain::ResultSet.new(id: "test_id1", nodes: input_nodes1)
    rs1.save
    
    loaded_rs1 = Xplain::ResultSet.load("test_id1")

    
    assert_same_result_set rs1, loaded_rs1

  end

  def test_load_two_rs_two_level
    input_nodes1 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes1.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    input_nodes2 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1rs2"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p3"), id: "np3")
    ]
    input_nodes2.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1rs2"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2rs2")]
    
    rs1 = Xplain::ResultSet.new(id: "test_id1", nodes: input_nodes1)
    rs2 = Xplain::ResultSet.new(id: "test_id2", nodes: input_nodes2)
    rs1.save
    rs2.save
    
    loaded_rs1 = Xplain::ResultSet.load("test_id1")
    loaded_rs2 = Xplain::ResultSet.load("test_id2")
    
    assert_same_result_set rs1, loaded_rs1
    assert_same_result_set rs2, loaded_rs2
  end
  
  def test_load_level3_set
    input_nodes1 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes1.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    input_nodes1[1].children = [Xplain::Node.new(item: Xplain::Entity.new("_:p2.1"), id: "np2.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p2.2"), id: "np2.2")]
    
    #setting level 3
    input_nodes1.first.children.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1.1"), id: "np1.1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.1.2"), id: "np1.1.2")]
    
    rs1 = Xplain::ResultSet.new(id: "test_id1", nodes: input_nodes1)
    rs1.save
    
    loaded_rs1 = Xplain::ResultSet.load("test_id1")

    
    assert_same_result_set rs1, loaded_rs1
  end
  
  def test_remove_set
    insert_rs = "INSERT DATA{ <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://purl.org/dc/terms/title> \"Set 2\". }"
    rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://purl.org/dc/terms/title", "Set 2"]
    ]
    items_rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1.1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1.2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]
    ]
    
    insert_items = "INSERT DATA{#{items_rs2_triples.map{|triple| triple.map{|r| "<#{r}>"}.join(" ")}.join(".")} }"
    @sparql_client.update(insert_rs)
    @sparql_client.update(insert_items)

    insert_rs = "INSERT DATA{ <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://purl.org/dc/terms/title> \"Set 1\". }"
    rs_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://purl.org/dc/terms/title", "Set 1"]
    ]
    items_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1.1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1.2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]
    ]
    
    insert_items = "INSERT DATA{#{items_triples.map do|triple| 
      triple.map do |r|
        if r == triple.last && triple[1].include?("index") 
          r
        else
          "<#{r}>"
        end
      end.join(" ")
    end.join(".")} }"
    @sparql_client.update(insert_rs)
    @sparql_client.update(insert_items)

     input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    
    rs = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes, title: "Set 1")

    rs.delete

    all_triples = get_triples_array("SELECT * WHERE{?s ?p ?o}")
    triples_to_remove = rs_triples + items_triples
    intersection = all_triples & triples_to_remove
    assert_true intersection.empty?, "TRIPLES NOT REMOVED: \n  " << intersection.inspect
    rs2_all_triples = rs2_triples + items_rs2_triples
    
    intersection = all_triples & rs2_all_triples
    
    assert_equal Set.new(intersection), Set.new(rs2_all_triples), "TRIPLES THAT SHOULDN'T BE REMOVED: \n  " << (rs2_all_triples - intersection).inspect
  end
  
  def test_load_all_resultsets
    insert_rs = "INSERT DATA{ <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://purl.org/dc/terms/title> \"Set 2\". }"
    rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://purl.org/dc/terms/title", "Set 2"]
    ]
    items_rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1", "#{@xplain_ns}index", "1"],
      [ "#{@xplain_ns}npt1", "#{@dcterms}title", "_:p1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1.1", "#{@xplain_ns}index", "1"],
      [ "#{@xplain_ns}npt1.1", "#{@dcterms}title", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1.2", "#{@xplain_ns}index", "2"],
      [ "#{@xplain_ns}npt1.2", "#{@dcterms}title", "_:p1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt2", "#{@xplain_ns}index", "2"],
      [ "#{@xplain_ns}npt2", "#{@dcterms}title", "_:p2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]
    ]
    
    insert_items = "INSERT DATA{#{items_rs2_triples.map do|triple| 
      triple.map do |r|
        if r == triple.last && triple[1].include?("index") 
          r
        else
          "<#{r}>"
        end
      end.join(" ")
    end.join(".")} }"

    @sparql_client.update(insert_rs)
    @sparql_client.update(insert_items)

    insert_rs = "INSERT DATA{ <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://purl.org/dc/terms/title> \"Set 1\". }"
    rs_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://purl.org/dc/terms/title", "Set 1"]
    ]
    items_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"],
      [ "_:p1", "#{@dcterms}title", "_:p1"],
      [ "_:p1", "#{@xplain_ns}item_type", "Xṕlain::Entity"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1.1", "#{@xplain_ns}index", "1"],
      [ "_:p1.1", "#{@dcterms}title", "_:p1.1"], 
      [ "_:p1.1", "#{@xplain_ns}item_type", "Xṕlain::Entity"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1.2", "#{@xplain_ns}index", "2"],
      [ "_:p1.2", "#{@dcterms}title", "_:p1.2"],
      [ "_:p1.2", "#{@xplain_ns}item_type", "Xṕlain::Entity"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"],
      [ "_:p2", "#{@dcterms}title", "_:p2"],
      [ "_:p2", "#{@xplain_ns}item_type", "Xṕlain::Entity"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]
    ]
    
    insert_items = "INSERT DATA{#{items_triples.map do|triple| 
      triple.map do |r|
        if r == triple.last && triple[1].include?("index") 
          r
        else
          "<#{r}>"
        end
      end.join(" ")
    end.join(".")} }"

    @sparql_client.update(insert_rs)
    @sparql_client.update(insert_items)
    
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    
    expected_rs1 = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes, title: "Set 1")
    
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "npt1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "npt2")
    ]
    
    input_nodes.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "npt1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "npt1.2")]
    
    expected_rs2 = Xplain::ResultSet.new(id: "test_id2", nodes: input_nodes, title: "Set 2")
    
    all_sets = Xplain::ResultSet.load_all
    actual_rs1, actual_rs2 = all_sets.select{|s| s.id == "test_id"}.first, all_sets.select{|s| s.id == "test_id2"}.first
    assert_same_result_set actual_rs1, expected_rs1
    assert_same_result_set actual_rs2, expected_rs2
 
  end
  
  def test_load_all_topological_ordered
    insert_stmt = "INSERT DATA{\n 
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://purl.org/dc/terms/title> \"Set 1\".\n\n 
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <#{@xplain_ns}intention> \"Xplain::KeywordSearch.new(keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://purl.org/dc/terms/title> \"Set 2\". \n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id').keyword_search(keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id3> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id3> <http://purl.org/dc/terms/title> \"Set 3\".\n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id3> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id2').keyword_search(keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.1> <http://purl.org/dc/terms/title> \"Set 3.1\".\n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.1> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id3').keyword_search(keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.2> <http://purl.org/dc/terms/title> \"Set 3.2\".\n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.2> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id3').keyword_search(keyword_phrase: 'test')\".\n\n
    }"
    
    @sparql_client.update(insert_stmt)
    
    actual_sets = Xplain::ResultSet.load_all_tsorted().map{|rs| rs.id}
    expected_sets = ["test_id", "test_id2", "test_id3","test_id3.1", "test_id3.2"]
    alt_expected_sets = ["test_id", "test_id2", "test_id3","test_id3.2", "test_id3.1"]
    
    assert_true((expected_sets == actual_sets || alt_expected_sets == actual_sets), "ACTUAL SETS: \n  " << actual_sets.inspect )

 
  end
  
  def test_load_exploration_only
    insert_stmt = "INSERT DATA{\n 
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <http://purl.org/dc/terms/title> \"Set 1\".\n\n 
    <http://tecweb.inf.puc-rio.br/xplain/test_id> <#{@xplain_ns}intention> \"Xplain::KeywordSearch.new(keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://purl.org/dc/terms/title> \"Set 2\". \n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id').keyword_search(keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id3> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id3> <http://purl.org/dc/terms/title> \"Set 3\".\n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id3> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id2').keyword_search(keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.1> <http://purl.org/dc/terms/title> \"Set 3.1\".\n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.1> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id3').keyword_search(visual:    true, keyword_phrase: 'test')\".\n\n
    
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.2> <http://purl.org/dc/terms/title> \"Set 3.2\".\n\n
    <http://tecweb.inf.puc-rio.br/xplain/test_id3.2> <#{@xplain_ns}intention> \"Xplain::ResultSet.load('test_id3').keyword_search(keyword_phrase: 'test')\".\n\n
    }"
    
    @sparql_client.update(insert_stmt)
    
    actual_sets = Xplain::ResultSet.load_all_tsorted_exploration_only().map{|rs| rs.id}
    expected_sets = ["test_id", "test_id2", "test_id3", "test_id3.2"]
    alt_expected_sets = ["test_id", "test_id2", "test_id3","test_id3.2"]
    
    assert_true((expected_sets == actual_sets || alt_expected_sets == actual_sets), "ACTUAL SETS: \n  " << actual_sets.inspect )

    
  end
  
  #TODO Finish this test
  def test_load_ordered_result_set
        insert_rs = "INSERT DATA{ <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/ResultSet>.
    <http://tecweb.inf.puc-rio.br/xplain/test_id2> <http://purl.org/dc/terms/title> \"Set 2\". }"
    rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://purl.org/dc/terms/title", "Set 2"]
    ]
    items_rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt2", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt2.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt2.2", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1.2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.2"],
      [ "#{@xplain_ns}npt1", "#{@xplain_ns}index", "2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]
    ]
    
    insert_items = "INSERT DATA{#{items_rs2_triples.map do|triple| 
      triple.map do |r|
        if r == triple.last && triple[1].include?("index") 
          r
        else
          "<#{r}>"
        end
      end.join(" ")
    end.join(".")} }"

    @sparql_client.update(insert_rs)
    @sparql_client.update(insert_items)
    
    assert true

  end
  
  def test_save_session
    input_nodes1 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes1.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    input_nodes2 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "npt1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "npt2")
    ]
    input_nodes2.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "npt1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "npt1.2")]
    
    rs1 = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes1)
    rs1.save
    session = Xplain::Session.new("test_session")
    session << rs1
    
    rs2 = Xplain::ResultSet.new(id: "test_id2", nodes: input_nodes2)
    rs2.save
    session << rs2
    
    rs1_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://purl.org/dc/terms/title", "Set 1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1.1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np1.2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]

    ]
    rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://purl.org/dc/terms/title", "Set 2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1.1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt1.2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      [ "#{@xplain_ns}npt2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]
    ]
    session_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_session", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/Session"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_session", "http://tecweb.inf.puc-rio.br/xplain/contains_set", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_session", "http://tecweb.inf.puc-rio.br/xplain/contains_set", "http://tecweb.inf.puc-rio.br/xplain/test_id2"]
    ]
    
    expected_triples = session_triples + rs1_triples + rs2_triples
    all_triples = get_triples_array("SELECT * WHERE{?s ?p ?o}")
    
    assert_equal Set.new(expected_triples), Set.new(expected_triples & all_triples), "Difference: \n" << (expected_triples - all_triples).inspect
 
  end
  

  
  def test_load_session
    input_nodes = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "np1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "np2")
    ]
    
    input_nodes.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "np1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "np1.2")]
    
    expected_rs1 = Xplain::ResultSet.new(id: "test_id", nodes: input_nodes, title: "Set 1")
    
    input_nodes2 = [
      Xplain::Node.new(item: Xplain::Entity.new("_:p1"), id: "npt1"),
      Xplain::Node.new(item: Xplain::Entity.new("_:p2"), id: "npt2")
    ]
    
    input_nodes2.first.children = [Xplain::Node.new(item: Xplain::Entity.new("_:p1.1"), id: "npt1.1"), Xplain::Node.new(item: Xplain::Entity.new("_:p1.2"), id: "npt1.2")]
    
    expected_rs2 = Xplain::ResultSet.new(id: "test_id2", nodes: input_nodes2, title: "Set 2")

    rs1_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id", "http://purl.org/dc/terms/title", "Set 1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      ["_:p1", "http://purl.org/dc/terms/title", "_:p1"],
      ["_:p1", "#{@xplain_ns}item_type", "Xplain::Entity"],
      [ "#{@xplain_ns}np1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://purl.org/dc/terms/title", "_:p1.1"],
      ["_:p1.1", "#{@xplain_ns}item_type", "Xplain::Entity"],
      [ "#{@xplain_ns}np1.1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://purl.org/dc/terms/title", "_:p12"],
      [ "#{@xplain_ns}np1.2", "#{@xplain_ns}index", "2"],
      ["_:p1.2", "#{@xplain_ns}item_type", "Xplain::Entity"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/np1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/np1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://purl.org/dc/terms/title", "_:p2"],
      [ "#{@xplain_ns}np2", "#{@xplain_ns}index", "2"],
      ["_:p2", "#{@xplain_ns}item_type", "Xplain::Entity"], 
      ["http://tecweb.inf.puc-rio.br/xplain/np2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]

    ]
    rs2_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/ResultSet"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_id2", "http://purl.org/dc/terms/title", "Set 2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      ["_:p1", "http://purl.org/dc/terms/title", "_:p1"],
      ["_:p1", "#{@xplain_ns}item_type", "Xplain::Entity"],
      [ "#{@xplain_ns}npt1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      ["_:p1.1", "http://purl.org/dc/terms/title", "_:p1.1"],
      ["_:p1.1", "#{@xplain_ns}item_type", "Xplain::Entity"],
      [ "#{@xplain_ns}npt1.1", "#{@xplain_ns}index", "1"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.1", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.1"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      ["_:p1.2", "http://purl.org/dc/terms/title", "_:p1.2"],
      ["_:p1.2", "#{@xplain_ns}item_type", "Xplain::Entity"],
      [ "#{@xplain_ns}npt1.2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt1.2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p1.2"],
      ["http://tecweb.inf.puc-rio.br/xplain/npt1", "http://tecweb.inf.puc-rio.br/xplain/children", "http://tecweb.inf.puc-rio.br/xplain/npt1.2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/included_in", "http://tecweb.inf.puc-rio.br/xplain/test_id2"],
      ["_:p2", "http://purl.org/dc/terms/title", "_:p2"],
      ["_:p2", "#{@xplain_ns}item_type", "Xplain::Entity"],
      [ "#{@xplain_ns}npt2", "#{@xplain_ns}index", "2"], 
      ["http://tecweb.inf.puc-rio.br/xplain/npt2", "http://tecweb.inf.puc-rio.br/xplain/has_item", "_:p2"]
    ]
    session_triples = [
      ["http://tecweb.inf.puc-rio.br/xplain/test_session", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://tecweb.inf.puc-rio.br/xplain/Session"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_session", "#{@dcterms}title", "test session"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_session", "http://tecweb.inf.puc-rio.br/xplain/contains_set", "http://tecweb.inf.puc-rio.br/xplain/test_id"],
      ["http://tecweb.inf.puc-rio.br/xplain/test_session", "http://tecweb.inf.puc-rio.br/xplain/contains_set", "http://tecweb.inf.puc-rio.br/xplain/test_id2"]
    ]
    
    session_rs_triples = session_triples + rs1_triples + rs2_triples
    sparql_insert = "INSERT DATA{#{session_rs_triples.map do|triple| 
      triple.map do |r|
        if r == triple.last && triple[1].include?("index") 
          r
        elsif r == triple.last && (triple[1].include?("title") || triple[1].include?("item_type")) && !(r == triple.first)
          "\"#{r}\""
        else
          "<#{r}>"
        end
      end.join(" ")
    end.join(".")} }"

    @sparql_client.update(sparql_insert)
    
    session_found = Xplain::Session.find_by_title("test session").first
    
    assert_false session_found.nil?
    assert_equal "test session", session_found.title
    assert_equal "test_session", session_found.id
    assert_equal 2, session_found.each_result_set_tsorted.size
    
    rs1 = session_found.each_result_set_tsorted.select{|rs| rs.id == "test_id"}.first
    rs2 = session_found.each_result_set_tsorted.select{|rs| rs.id == "test_id2"}.first
    assert_same_result_set expected_rs1, rs1
    assert_same_result_set expected_rs2, rs2
     
  end
  
  def test_list_session_titles
    
    insert_data = "INSERT DATA{
      <http://tecweb.inf.puc-rio.br/xplain/test_session> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/Session>.
      <http://tecweb.inf.puc-rio.br/xplain/test_session> <#{@dcterms}title> \"test session\".
      <http://tecweb.inf.puc-rio.br/xplain/test_session2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://tecweb.inf.puc-rio.br/xplain/Session>.
      <http://tecweb.inf.puc-rio.br/xplain/test_session2> <#{@dcterms}title> \"test session 2\".
    }"
    
    @sparql_client.update(insert_data)
    
    session_names = Set.new(Xplain::Session.list_titles)
    
    assert_equal Set.new(["test session", "test session 2"]), session_names

  end

end

