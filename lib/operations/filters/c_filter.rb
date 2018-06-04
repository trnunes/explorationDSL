class CFilter < SimpleFilter
  def initialize(*args)
    @filter_code = args.first
    if !@filter_code
      raise MissingParameterException("you should provide a filter code here!")
    end
  end
  def filter(node)
    return eval("lambda{#{@filter_code}}").call node.item
  end
end