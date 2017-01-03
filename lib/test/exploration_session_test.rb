require "test/unit"

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
require './model/ranked_set'

require './aux/grouping_expression.rb'
require './aux/ranking_functions'
require './aux/mapping_functions'

require 'set'

require './adapters/rdf/rdf_data_server.rb'
require './adapters/rdf/rdf_filter.rb'
require './adapters/rdf/rdf_nav_query.rb'

require "./model/exploration_session"

class ExplorationSessionTest < Test::Unit::TestCase
  
  def setup

  end
  
  def test_create_session
    session = ExplorationSession.new("session")
    session.description = "session description"
    s0 = Xset.new{|s| s.id = "s0"}
    session.add_set(s0);
    session.save()
    session = ExplorationSession.load(session.id)
    assert_equal 1, session.position_of(s0)    
    s1 = Xset.new{|s| s.id = "s1"}
    session.add_set(s1)
    assert_equal 2, session.position_of(s1)
  end
  
end