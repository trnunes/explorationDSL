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

require './exploration_functions/operation'
require './exploration_functions/find_relations'
require './exploration_functions/pivot2'
require './exploration_functions/refine'
require './exploration_functions/group'
require './exploration_functions/map'
require './exploration_functions/flatten'
require './exploration_functions/union'
require './exploration_functions/intersection'
require './exploration_functions/diff'
require './exploration_functions/rank'
require './exploration_functions/select'

require './filters/filtering'
require './filters/contains'
require './filters/equals'
require './filters/keyword_match'
require './filters/match'
require './filters/in_range'
require './filters/image_equals'
require './filters/compare'
require './filters/by_image'

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

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'
require './aux/hash_helper'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/rdf_filter2.rb'
require './adapters/rdf/rdf_nav_query2.rb'
require './adapters/rdf/cache.rb'

class XpairUnitTest < Test::Unit::TestCase
  
end
Explorable.use_cache(false)
