Dir["/Users/tnunes/development/xpair/mixins/*.rb"].each {|file| require file }
Dir["/Users/tnunes/development/xpair/model/*.rb"].each {|file| require file }
Dir["/Users/tnunes/development/xpair/aux/*.rb"].each {|file| require file }
Dir["/Users/tnunes/development/xpair/adapters/rdf/*.rb"].each {|file| require file }

require 'mixins/hash_explorable'
require 'mixins/enumerable'
require 'mixins/persistable'
require 'filters/filtering'
require 'filters/contains'
require 'filters/equals'
require 'filters/keyword_match'
require 'filters/match'
require 'filters/in_range'


require 'model/item'
require 'model/xset'
require 'model/entity'
require 'model/ranked_set'

require 'aux/grouping_expression.rb'
require 'aux/ranking_functions'
require 'aux/mapping_functions'

require 'set'

require 'adapters/rdf/rdf_data_server.rb'
require 'adapters/rdf/rdf_filter.rb'
require 'adapters/rdf/rdf_nav_query.rb'

$PAGINATE = 10
##TODO BUGS TO CORRECT
## contains_one does not admit literals
##
