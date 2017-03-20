require './test/xpair_unit_test'

class EvalPapersFunctionalTest < XpairUnitTest

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
      Xpair::Literal.new(2000) => {},
      Xpair::Literal.new(1998) => {},
      Xpair::Literal.new(2010) => {}
    }

    assert_equal expected_extension, publication_years.extension
    
    meanYear = publication_years.map{|mf| mf.avg}
    expected_extension = {
      Xpair::Literal.new(2002) => {}
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
    
    papers_with_keywords = papers_set.refine{|f| f.contains_one(relations: [Relation.new("_:keywords")], values: keywords)}
    
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
    
    ranked_papers = papers_with_keywords.rank{|f| f.by_relation([papers_with_keywords.map{|mf| mf.image_count(related_papers_citations)}])}
    
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
    
    citations_published_same_journal = citations.refine{|f| f.equals(relations: [Relation.new("_:publishedOn")], values: submitted_journal.first)} 
    
    expected_extension = {
      Entity.new("_:p2") => {},
      Entity.new("_:p4") => {}
    }
    
    assert_equal expected_extension, citations_published_same_journal.extension
  end
  
end