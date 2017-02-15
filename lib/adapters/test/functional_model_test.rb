require "test/unit"
require "rdf"

require './mixins/auxiliary_operations'
require './mixins/hash_explorable'
require './mixins/enumerable'
require './mixins/persistable'
require './filters/filtering'
require './filters/contains'
require './filters/equals'
require './filters/keyword_match'
require './filters/match'
require './filters/in_range'
require './model/item'
require './model/xset'
require './model/entity'
require './model/relation'
require './model/type'
require './model/ranked_set'

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/rdf_filter.rb'
require './adapters/rdf/rdf_nav_query.rb'

class FunctionalTest < Test::Unit::TestCase
  def setup
    @graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o1")]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:r1"), RDF::URI("_:o2")]      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:r1"), RDF::URI("_:o2")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:r1"), RDF::URI("_:o3")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o4")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:r2"), RDF::URI("_:o5")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:r2"), RDF::URI("_:o6")]
    end
    
    @server = RDFDataServer.new(@graph)
    
    @correlate_graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:o1"), RDF::URI("_:r1"), RDF::URI("_:p1")]
      graph << [RDF::URI("_:o1"), RDF::URI("_:r1"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:o2"), RDF::URI("_:r1"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p1"), RDF::URI("_:r1"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:o2"), RDF::URI("_:r1"), RDF::URI("_:p2")]
    end
    
    @correlate_server = RDFDataServer.new(@correlate_graph)  
    
    expected_extension = {
      Entity.new("_:a1") => Set.new([3]),
      Entity.new("_:a2") => Set.new([2])
    }
    
    papers_graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:cite"), RDF::URI("_:p4")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p2")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p7"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p7"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p8"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p8"),  RDF::URI("_:cite"), RDF::URI("_:p3")]
      graph << [RDF::URI("_:p9"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      graph << [RDF::URI("_:p10"),  RDF::URI("_:cite"), RDF::URI("_:p5")]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:submittedTo"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a1") ]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a2") ]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a2")]

      graph << [RDF::URI("_:p2"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal2")]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publishedOn"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:journal1"),  RDF::URI("_:releaseYear"), "2005"]
      graph << [RDF::URI("_:journal2"),  RDF::URI("_:releaseYear"), "2010"]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:keywords"), RDF::URI("_:k3")]      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:keywords"), RDF::URI("_:k2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:keywords"), RDF::URI("_:k1")]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:publicationYear"), "2000"]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:publicationYear"), "1998"]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:publicationYear"), "2010"]     
    end

    @papers_server = RDFDataServer.new(papers_graph)
      
  end
  
  def test_task_eval_paper
    papers_set = Xset.new do |s|
      s.server = @papers_server
    end
    
    s0 =  Xset.new do |s|
      s << Entity.new("_:paper1")
      s.resulted_from = papers_set
    end    
    
    s0.server = @papers_server
    
    #CALCULANDO o ano médio das referências
    citations = s0.pivot_forward(["_:cite"])

    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p3") => {},
      Entity.new("_:p4") => {}
    }
    assert_equal citations.extension, expected_extension
    
    publication_years = citations.pivot_forward(["_:publicationYear"])
    expected_extension = {
      2000 => {},
      1998 => {},
      2010 => {}
    }

    assert_equal expected_extension, publication_years.extension
    
    meanYear = publication_years.map{|mf| mf.avg}
    expected_extension = {
      2002 => {}
    }
    assert_equal expected_extension, meanYear.extension
    
    #Buscando papers possivelmente relacionados que não foram citados
    keywords = s0.pivot_forward(["_:keywords"])
    
    expected_extension = {
      Entity.new("_:k1") => {},
      Entity.new("_:k2") => {},
      Entity.new("_:k3") => {}
    }
    
    assert_equal expected_extension, keywords.extension
    
    #CONTAINS ONE - Alternative
    # all_keywords = papers_set.pivot("_:keywords")
    # papers_with_keywords = keywords.pivot_backward("_:keywords")}
    
    papers_with_keywords = papers_set.refine{|f| f.contains_one("_:keywords", keywords)}
    
    expected_extension = {
      Entity.new("_:paper1")=>{},
      Entity.new("_:p2")    =>{},
      Entity.new("_:p3")    =>{},
      Entity.new("_:p5")    =>{}
    }
    
    assert_equal expected_extension, papers_with_keywords.extension
    
    related_papers_citations = papers_with_keywords.pivot_backward(["_:cite"])
    expected_extension = {
      Entity.new("_:paper1") => {},
      Entity.new("_:p6") => {},
      Entity.new("_:p7") => {},
      Entity.new("_:p8") => {},
      Entity.new("_:p9") => {},
      Entity.new("_:p10") => {}     
    }
    
    assert_equal expected_extension, related_papers_citations.extension
    
    ranked_papers = papers_with_keywords.rank{|f| f.each_image_count(related_papers_citations)}
    
    expected_extension = {
      Entity.new("_:p5") => {}, 
      Entity.new("_:p3") => {}, 
      Entity.new("_:p2") => {}, 
      Entity.new("_:paper1") => {}
    }
    
    assert_equal expected_extension, ranked_papers.extension
    
    not_cited_relevant_papers = ranked_papers.diff(citations).diff(s0)
    
    expected_extension = {
      Entity.new("_:p5") => {}
    }
    
    assert_equal expected_extension, not_cited_relevant_papers.extension

    ##AVALIANDO AUTO REFERÊNCIAS
    authors = s0.pivot_forward(["_:author"])
    
    expected_extension = {
      Entity.new("_:a1") => {},
      Entity.new("_:a2") => {}
    }
    
    assert_equal expected_extension, authors.extension
    
    papers_of_authors = authors.pivot_backward(["_:author"])
    
    expected_extension = {
      Entity.new("_:paper1") => {},
      Entity.new("_:p2") => {},
      Entity.new("_:p3") => {},
      Entity.new("_:p5") => {}
    }
    
    assert_equal expected_extension, papers_of_authors.extension
    
    intersection = citations.intersect(papers_of_authors)
    
    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p3") => {},
    }
    assert_equal expected_extension, intersection.extension
    
    missing_papers_count = intersection.map{|m| m.count}
    
    expected_extension = {
      2 => {}
    }
    
    #Avaliando quantas citações foram também publicadas no mesmo journal
    submitted_journal = s0.pivot_forward(["_:submittedTo"])
    
    expected_extension = {
      Entity.new("_:journal1") => {}
    }
    assert_equal expected_extension, submitted_journal.extension
    
    citations_published_same_journal = citations.refine{|f| f.equals("_:publishedOn", submitted_journal.first)} 
    
    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p4") => {}
    }
    
    assert_equal expected_extension, citations_published_same_journal.extension
  end
  
  def cube_task
    papers_graph = RDF::Graph.new do |graph|
      graph << [RDF::URI("_:p1"),  RDF::URI("_:max_age"), 75]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:city"), "Rio"]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:year"), 2006]
      graph << [RDF::URI("_:p1"),  RDF::URI("_:gender"), "male"]
      
      graph << [RDF::URI("_:p1.2"),  RDF::URI("_:max_age"), 77]
      graph << [RDF::URI("_:p1.2"),  RDF::URI("_:city"), "Rio"]
      graph << [RDF::URI("_:p1.2"),  RDF::URI("_:year"), 2006]
      graph << [RDF::URI("_:p1.2"),  RDF::URI("_:gender"), "male"]
      
      graph << [RDF::URI("_:p2"),  RDF::URI("_:max_age"), 67]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:city"), "Rio"]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:year"), 2010]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:gender"), "male"]
      
      
      graph << [RDF::URI("_:p3"),  RDF::URI("_:max_age"), 50]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:city"), "São Paulo"]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:year"), 2010]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:gender"), "male"]
      
      graph << [RDF::URI("_:p4"),  RDF::URI("_:max_age"), 69]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:city"), "São Paulo"]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:year"), 2006]
      graph << [RDF::URI("_:p4"),  RDF::URI("_:gender"), "female"]
      
      graph << [RDF::URI("_:p5"),  RDF::URI("_:max_age"), 68]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:city"), "Rio"]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:year"), 2010]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:gender"), "female"]
      
    end

    @papers_server = RDFDataServer.new(papers_graph)
    
    group_by_1 = {
      "Rio" => Set.new(["_:p1", "_:p2"]),
      "São Paulo" => Set.new(["_:p3", "_:p4"])
    }
    
    group_by_3 = {      
      2006 => Set.new(["_:p1", "_:p1.2", "_:p4"]),
      2010 => Set.new(["_:p2", "_:p3", "_:p5"])      
    }
    
    pivoted_group = {
      "Rio" => {
        2006 => {
          "male" => Set.new(["_:p1", "_:p1.2"]),
          "female" => Set.new([])
        },
        2010 => {
          "male" => Set.new(["_:p2"]),
          "female" => Set.new(["_:p5"])
        }       
      },
      "São Paulo" => {
        2006 => Set.new(["_:p4"]),
        2010 => Set.new(["_:p3"])
      }
    }
    
  end
    
  # def test_task_lobbying
  #
  #   bills_graph = RDF::Graph.new do |g|
  #     #TODO MOUNT BILLS GRAPH
  #   end
  #
  #   bills_set = Xset.new
  #   bills_set.server = RDFDataServer.new(bills_graph)
  #
  #   #S1 - FINDING ETHANOL BILLS
  #   relations = bills_set.relations
  #
  #   ethanol_items = bills_set.refine{|f| f.match("_:title", "ethanol")}
  #
  #   types = ethanol_items.pivot_forward("_:type")}
  #
  #   ethanol_bills = ethanol_items.refine{|f| f.equal("_:type", "Bill")}
  #
  #   #S2 - Finding the total by Bill
  #   specific_issues = ethanol_bills.pivot_forward("_:specifcIssue")
  #
  #   reports = specific_issues.pivot_forward("_:report")
  #
  #   totals = reports.map{|m| m.scan(/$ ^[+-]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{2}/)}
  #
  #   #The sets are by nature related with the elements of previous sets. There has to be natural to partitionate sets by domain
  #   aggregated_totals_by_issue = specific_issues.each_image(totals).map{|m| m.sum}
  #
  #   ethanol_bills.rank{|r| r.score_by(aggregated_totals_by_issue)}
  #
  #   #COMPANIES THAT SPENT MORE MONEY IN ETHANOL LOBBYING
  #   bills_clients = ethanol_bills.pivot_forward("_:hasClient")
  #
  #   all_bills_for_clients = bills_clients.pivot_backward("_:has_client")
  #
  #   other_bills = all_bills_for_clients.intersect(bills_clients)
  #
  #   ranked_clients = bills_clients.rank{|r| r.local_image(totals)}
  #
  #
  # end
  #
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

    semiconductor_ipcs = ipcs.refine{|f| f.keyword_match([["semiconductor",  "silicon", "led", "insulator","transistor"]])}
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
    
    patents_2001_2002 = semiconductor_patents.refine{|f| f.in_range("_:publication_year", 2001, 2004)}
    expected_extension = {
      Entity.new("_:p1") => { },
      Entity.new("_:p2") => { }
    }
    
    assert_equal expected_extension, patents_2001_2002.extension

    patents_2003_2004 = semiconductor_patents.refine{|f| f.in_range("_:publication_year", 2005, 2007)}
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