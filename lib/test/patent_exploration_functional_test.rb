require './test/xpair_unit_test'

class PatentExplorationFunctionalTest < XpairUnitTest

  def test_task_patent_exploration
    patents_graph = RDF::Graph.new do |g|
      g << [RDF::URI("_:p1"), RDF::URI("_:ipc"), RDF::URI("_:IPC1")]
      g << [RDF::URI("_:p1"), RDF::URI("_:ipc"), RDF::URI("_:IPC2")]
      g << [RDF::URI("_:p2"), RDF::URI("_:ipc"), RDF::URI("_:IPC1")]
      g << [RDF::URI("_:p2"), RDF::URI("_:ipc"), RDF::URI("_:IPC2")]
      g << [RDF::URI("_:p3"), RDF::URI("_:ipc"), RDF::URI("_:IPC3")]
      g << [RDF::URI("_:p3"), RDF::URI("_:ipc"), RDF::URI("_:IPC2")]
      g << [RDF::URI("_:p3"), RDF::URI("_:ipc"), RDF::URI("_:IPC4")]
      g << [RDF::URI("_:p4"), RDF::URI("_:ipc"), RDF::URI("_:IPC5")]
      g << [RDF::URI("_:p4"), RDF::URI("_:ipc"), RDF::URI("_:IPC2")]
      
      g << [RDF::URI("_:IPC1"), RDF::URI("_:r1"), "semiconductor"]
      g << [RDF::URI("_:IPC1"), RDF::URI("_:r2"), "silicon"]
      g << [RDF::URI("_:IPC1"), RDF::URI("_:r1"), "led"]
      g << [RDF::URI("_:IPC2"), RDF::URI("_:r1"), "insulator"]
      g << [RDF::URI("_:IPC3"), RDF::URI("_:r3"), RDF::URI("_:transistor")]
      g << [RDF::URI("_:IPC4"), RDF::URI("_:r3"), RDF::URI("_:transistor")]
      
      g << [RDF::URI("_:p1"), RDF::URI("_:publication_year"), 2002]
      g << [RDF::URI("_:p2"), RDF::URI("_:publication_year"), 2004]
      g << [RDF::URI("_:p3"), RDF::URI("_:publication_year"), 2005]
      g << [RDF::URI("_:p4"), RDF::URI("_:publication_year"), 2006]

    end

    server = RDFDataServer.new(patents_graph)

    patents_dataset = Xset.new
    patents_dataset.server = server

    ipcs = patents_dataset.pivot_forward(["_:ipc"])
    expected_extension = {
      Entity.new("_:IPC1") =>{},
      Entity.new("_:IPC2") =>{},
      Entity.new("_:IPC3") =>{},
      Entity.new("_:IPC4") =>{},
      Entity.new("_:IPC5") =>{},
    }
    
    assert_equal expected_extension, ipcs.extension

    semiconductor_ipcs = ipcs.refine{|f| f.keyword_match(keywords: [["semiconductor",  "silicon", "led", "insulator","transistor"]])}
    expected_extension = {
      Entity.new("_:IPC1") =>{},
      Entity.new("_:IPC2") =>{},
      Entity.new("_:IPC3") =>{},
      Entity.new("_:IPC4") =>{}
    }
    
    assert_equal expected_extension, semiconductor_ipcs.extension

    semiconductor_patents = semiconductor_ipcs.pivot_backward(["_:ipc"])
    expected_extension = {
      Entity.new("_:p1") => { },
      Entity.new("_:p2") => {},
      Entity.new("_:p3") => {},
      Entity.new("_:p4") => {}      
    }
    
    assert_equal expected_extension, semiconductor_patents.extension
    
    patents_2001_2002 = semiconductor_patents.refine{|f| f.in_range(relations: [Relation.new("_:publication_year")], min: 2001, max: 2004)}
    expected_extension = {
      Entity.new("_:p1") => { },
      Entity.new("_:p2") => { }
    }
    
    assert_equal expected_extension, patents_2001_2002.extension

    patents_2003_2004 = semiconductor_patents.refine{|f| f.in_range(relations: [Relation.new("_:publication_year")], min: 2005, max: 2007)}
    expected_extension = {
      Entity.new("_:p3") => { },
      Entity.new("_:p4") => { }      
    }
    
    assert_equal expected_extension, patents_2003_2004.extension

    ipcs_2001_2002 = patents_2001_2002.pivot_forward(["_:ipc"]).intersect(semiconductor_ipcs)
    expected_extension = {
      Entity.new("_:IPC1") =>{ },
      Entity.new("_:IPC2") =>{}
    }
    
    assert_equal expected_extension, ipcs_2001_2002.extension

    ipcs_2003_2004 = patents_2003_2004.pivot_forward(["_:ipc"]).intersect(semiconductor_ipcs)
    expected_extension = {
      Entity.new("_:IPC2") =>{},
      Entity.new("_:IPC3") =>{},
      Entity.new("_:IPC4") =>{}      
    }
    
    assert_equal expected_extension, ipcs_2003_2004.extension

    ipcs_not_addressed_anymore = ipcs_2001_2002.diff(ipcs_2003_2004)
    expected_extension = {
      Entity.new("_:IPC1") =>{}
    }
    
    assert_equal expected_extension, ipcs_not_addressed_anymore.extension

    ipcs_started_to_be_addressed = ipcs_2003_2004.diff(ipcs_2001_2002)
    expected_extension = {
      Entity.new("_:IPC3") =>{},
      Entity.new("_:IPC4") =>{}      
    }    
    
    assert_equal expected_extension, ipcs_started_to_be_addressed.extension
  end
    
  
end