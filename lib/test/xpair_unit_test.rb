require "test/unit"
require "rdf"

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
require './model/item'
require './model/xset'
require './model/literal'
require './model/entity'
require './model/relation'
require './model/type'
require './model/ranked_set'

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