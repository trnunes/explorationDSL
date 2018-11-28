class BlazegraphDataServer < RDFDataServer
  def match_all(keyword_pattern, restriction_nodes = [], offset = 0, limit = 0)
    blaze_graph_search(keyword_pattern, restriction_nodes, offset, limit)
  end
  
  def blaze_graph_search(keyword_pattern, restriction_nodes = [], offset = 0, limit = 0)
    filters = []
    unions = []
    items = []
    label_clause = label_where_clause("?s", Xplain::Visualization.label_relations_for("rdfs:Resource"))
    label_clause = " OPTIONAL " + label_clause if !label_clause.empty?
    query = "select ?s ?p ?o ?ls where {#{values_clause("?s", restriction_nodes.map{|n|n.item})} ?o <http://www.bigdata.com/rdf/search#search> \" #{keyword_pattern.join(" ")}\". ?o <http://www.bigdata.com/rdf/search#matchAllTerms> \"true\" . ?s ?p ?o . #{label_clause}}"


    execute(query,{content_type: content_type, offset: offset, limit: limit}).each do |s|
      item = Xplain::Entity.new(Xplain::Namespace.colapse_uri(s[:s].to_s),  "rdfs:Resource")
      item.text = s[:ls].to_s
      item.add_server(self)
      items << item
    end
    items.sort{|i1, i2| i1.text <=> i2.text}
  end
end