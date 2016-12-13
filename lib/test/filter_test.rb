require "test/unit"
require "model/entity.rb"
require 'model/relation.rb'
require 'model/xset.rb'
require 'mode/filter.rb'

class ExplorableTest < Test::Unit::TestCase
  
  def setup
  end
  def test_to_source
    a = Xset.new("test_set")
    f = Filter.new("item == a", binding)
    assert_equal("Filter.new(\"item == Xset.load(\"test_set\")\")", f.to_source)
  end
  
  def test_to_proc
    a = 4
    f = Filter.new("item == a", binding)
    assert_equal(true, f.to_proc.call(a))
  end
end