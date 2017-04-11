require "pry"
require "test/unit"
require "rdf"
require 'linkeddata'
require './mixins/xpair'
require './mixins/hash_explorable'
require './mixins/auxiliary_operations'
require './mixins/enumerable'
require './mixins/persistable'
require './mixins/graph'


require './filters/filtering'
require './filters/contains'
require './filters/equals'
require './filters/keyword_match'
require './filters/match'
require './filters/in_range'
require './filters/image_equals'

require './grouping_functions/grouping'
require './grouping_functions/by_relation'

require './ranking_functions/ranking'
require './ranking_functions/alpha_sort'
require './ranking_functions/by_relation'

require './mapping_functions/mapping'
require './mapping_functions/average'
require './mapping_functions/count'
require './mapping_functions/image_count'



require './model/item'
require './model/xset'
require './model/literal'
require './model/entity'
require './model/relation'
require './model/type'
require './model/ranked_set'
require './model/xsubset'
require './model/namespace'

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'
require './aux/hash_helper'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/rdf_filter.rb'
require './adapters/rdf/rdf_nav_query.rb'

class XpairUnitTest < Test::Unit::TestCase
  
end