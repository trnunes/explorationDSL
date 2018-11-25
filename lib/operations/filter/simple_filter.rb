class SimpleFilter < GenericFilter
  include Xplain::FilterFactory

  def initialize(&block)
    super &block
    if(@frelation.nil?)
      raise MissingRelationException
    end
    if(@values.nil? || @values.compact.empty?)
      raise MissingValueException
    end
  end
end
