
class SimpleFilter
  attr_accessor :frelation, :values
  def initialize(relation, *values)
    if(relation.nil?)
      raise "The filtering relation cannot be nil!"
    end
    if(values.compact.empty?)
      raise "You should provide at least one filtering value!"
    end
    @frelation = relation
    @values = values
  end
end

class Equals < SimpleFilter
end

class LessThan < SimpleFilter
end

class LessThanEqual < SimpleFilter
end

class GreaterThan < SimpleFilter
end

class GreaterThanEqual < SimpleFilter
end

class Not < SimpleFilter
end

class EqualsOne < SimpleFilter
end

class Contains < SimpleFilter
end

class CompositeFilter
  attr_accessor :filters
  def initialize(filters)
    @filters = filters
  end
end

class And < CompositeFilter
end

class Or < CompositeFilter
end
