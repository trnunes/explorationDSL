class NotSupportedOperation < StandardError
  def initialize(msg = "This operation is currently not supported")
end