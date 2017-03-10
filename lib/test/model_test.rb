require './test/xpair_unit_test'

class ModelTest < XpairUnitTest

  def test_relation_eql
    assert_true !(Relation.new("id", true) == Relation.new("id", false))
  end  
end