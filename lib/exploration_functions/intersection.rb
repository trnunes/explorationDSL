module Explorable
  class Intersection < Explorable::Operation
    
    def eval
      start_time = Time.now
      mappings = {}

      intersection_items = @args[:input].each_item & @args[:target].each_item
      mappings = intersection_items.map{|item| [item, {}]}.to_h
      finish_time = Time.now
      puts "EXECUTED INTERSECT: " << (finish_time - start_time).to_s
      mappings
    end
    
    def expression
      "intersect(#{@args[:input]}, #{@args[:target]})"
    end
  end
  
  def intersect(target)
    args = {target: target}
    execute_operation(Intersection, args)
  end
end