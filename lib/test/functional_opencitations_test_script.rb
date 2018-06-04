require 'xplain'
requrie 'pry'

###
### Setting the namespaces for the opencitations dataset
###
Xplain::Namespace.new("uspat", "http://us.patents.aksw.org/")
Xplain::Namespace.new("fabio", "http://purl.org/spar/fabio/")
Xplain::Namespace.new("cito", "http://purl.org/spar/cito/")
Xplain::Namespace.new("c4o", "http://purl.org/spar/c4o/")
Xplain::Namespace.new("biro", "http://purl.org/spar/biro/")
Xplain::Namespace.new("spardatacite", "http://purl.org/spar/datacite/")
Xplain::Namespace.new("sparpro", "http://purl.org/spar/pro/")
Xplain::Namespace.new("prismstandard", "http://prismstandard.org/namespaces/basic/2.0/")
Xplain::Namespace.new("sparpro", "http://purl.org/spar/pro/")
Xplain::Namespace.new("frbr", "http://purl.org/vocab/frbr/core#")
Xplain::Namespace.new("w3iont", "https://w3id.org/oc/ontology/")

###
### Setting up the blazegraph server containing the open citations 
### dataset running at localhost, port 3001.
###
graph_url = "http://192.168.0.15:3001/blazegraph/namespace/kb/sparql"

# setting the blazegraph server as the default data server for the exploration tasks
Xplain.set_default_server class: BlazegraphDataServer, graph: graph_url

# instantiating the metarelation "has_type" that maps instances to their respective types 
has_type_relation = Xplain::SchemaRelation.new(id: "has_type")

# retrieving the image of the "has_type" metarelation which is the set of all types of the open citations dataset
all_types = has_type_relation.image

book_type = all_types.select{|type| type.item.id == "fabio:Book"}.first

workflow = Xplain.get_current_workflow
workflow.pivot(input: Xplain::ResultSet.new(nil, [book_type])){relation inverse "has_type"}
rs = workflow.execute()
rs.first.to_tree.children.each{|book_node| puts book_node.item.to_s}; puts

relations = workflow.last_executed.pivot{relation "relations"}.execute