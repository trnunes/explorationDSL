module Enumerable  
  def each_relation(&block)
    each do |item|
      if block_given?
        yield
      end
    end
  end
end
