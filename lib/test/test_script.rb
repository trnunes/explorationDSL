require 'forwardable'
require "pry"
require "test/unit"
require "rdf"
require 'linkeddata'
require './mixins/xpair'
require './mixins/explorable'
require './mixins/auxiliary_operations'
require './mixins/enumerable'
require './mixins/persistable'
require './mixins/graph'
require './mixins/indexing'
require './mixins/indexable'

require './model/item'
require './model/pair'
require './model/path_relation'
require './model/schema_relation'
require './model/computed_relation'
require './model/xset'
require './model/literal'
require './model/entity'
require './model/type'
require './model/ranked_set'
require './model/xsubset'
require './model/namespace'
require './model/session'

require './exploration_functions/operation'
require './exploration_functions/cursor'
require './exploration_functions/find_relations'
require './exploration_functions/pivot2'
require './exploration_functions/refine'
require './exploration_functions/group'
require './exploration_functions/map'
require './exploration_functions/flatten'
require './exploration_functions/union'
require './exploration_functions/join'
require './exploration_functions/intersection'
require './exploration_functions/diff'
require './exploration_functions/rank'
require './exploration_functions/select'
require './visualization/visualization'

require './filters/filtering'
require './filters/contains'
require './filters/equals'
require './filters/keyword_match'
require './filters/match'
require './filters/in_range'
require './filters/image_equals'
require './filters/compare'
require './filters/relation_compare'
require './filters/by_image'
require './filters/local_filter'
require './filters/operators/filtering_operator.rb'


require './grouping_functions/grouping'
require './grouping_functions/by_relation'
require './grouping_functions/by_domain'

require './ranking_functions/ranking'
require './ranking_functions/alpha_sort'
require './ranking_functions/by_relation'
require './ranking_functions/by_image'
require './ranking_functions/by_domain'

require './mapping_functions/mapping'
require './mapping_functions/average'
require './mapping_functions/count'
require './mapping_functions/image_count'
require './mapping_functions/user_defined'

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'
require './aux/hash_helper'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/sparql_query.rb'
require './adapters/rdf/rdf_filter2.rb'
require './adapters/rdf/rdf_nav_query2.rb'
require './adapters/rdf/cache.rb'

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
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p2"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p3"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p4"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p5"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p6"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p7"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p8"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p9"),      RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      graph << [RDF::URI("_:p10"),     RDF::URI("http://www.w3.org/2000/01/rdf-schema#type"), RDF::URI("http://tecweb/pns#Paper")]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:submittedTo"), RDF::URI("_:journal1")]
      
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a1") ]
      graph << [RDF::URI("_:paper1"),  RDF::URI("_:author"),RDF::URI("_:a2") ]
      graph << [RDF::URI("_:p2"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p3"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a1")]
      graph << [RDF::URI("_:p5"),  RDF::URI("_:author"), RDF::URI("_:a2")]
      graph << [RDF::URI("_:p6"),  RDF::URI("_:author"), RDF::URI("_:a2")]

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
    module Xpair::Visualization
        label_for_type "http://tecweb/pns#Paper", "_:author"
    end
    Explorable.use_cache false
xset = Xset.new('s0', '')
xset.add_item Entity.new('_:paper1', "rdf:Resource")
xset.add_item Entity.new('_:p2',  "rdf:Resource")
xset.add_item Entity.new('_:p3',  "rdf:Resource")
# xset.add_item Entity.new('_:p4')
xset.add_item Entity.new('_:p4', "rdf:Resource")
xset.add_item Entity.new('_:p6', "rdf:Resource")
# xset.add_item Entity.new('_:p7')
# xset.add_item Entity.new('_:p8')
# xset.add_item Entity.new('_:p9')
# xset.add_item Entity.new('_:p10')
xset.server = @papers_server

xset2 = Xset.new('s1', '')
xset2.add_item Entity.new('_:paper1',  "rdf:Resource")
xset2.add_item Entity.new('_:p2,  "rdf:Resource"')

xset3 = Xset.new('s1', '')
xset3.add_item Entity.new('_:a1',  "rdf:Resource")



rs = xset.refine{|f| f.compare(restrictions: [f.op.in(xset2)])}




g1 = xset.group{|gf| gf.by_relation(relations: [SchemaRelation.new("_:author", @papers_server)])}
g2 = g1.group{|gf| gf.by_relation(relations: [SchemaRelation.new("_:publicationYear")])}

rs = g2.refine{|rf| rf.by_image(restriction: "item.id == '_:p3'")}
g3  = xset.group{|gf| gf.by_relation(relations: [SchemaRelation.new("_:cite", @papers_server)])}
c = g3.map{|f| f.count}
r = c.rank{|f| f.by_image}

rf = xset.refine{|f| f.compare(restrictions: [f.op.equal(Entity.new("_:p3")), f.op.equal(Entity.new("_:p4"))])}
items = g2.select_items([Entity.new("_:p3")])
g1 = Xset.load('test_set').group{|gf| gf.by_relation(relations: [SchemaRelation.new("_:author")])}
p = xset.pivot(relations: [SchemaRelation.new("_:cite")])
p = xset.pivot(relations: [SchemaRelation.new("_:author", @papers_server)])
p = p.pivot(relations: [SchemaRelation.new("_:author", @papers_server)])

g2 = xset.group(image_set: xset3){|gf| gf.by_relation(relations: [SchemaRelation.new("_:author", @papers_server)])}

## refine by related set ###

p = xset.pivot(relations: [SchemaRelation.new("_:author")])
r = xset.refine{|f| f.relation_compare(relations: [p], connector: "AND", restrictions: [["=", Entity.new("_:a1")]])}
g = xset.group{|g| g.by_relation relations: [p]}
gd = p.group{|g| g.by_domain domain_set: xset}

