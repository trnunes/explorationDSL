require './test/xpair_unit_test'

class CubeTest < XpairUnitTest
  def test_cube
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
  
end