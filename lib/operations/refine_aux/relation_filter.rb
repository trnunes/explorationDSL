class RelationFilter < GenericFilter
  include Xplain::FilterFactory

  def initialize(&block)
    super &block
    if(@relation.nil?)
      raise MissingRelationException
    end
    if(@values.nil? || @values.compact.empty?)
      raise MissingValueException
    end
  end
end
