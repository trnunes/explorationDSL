module Explorable
  class Diff < Explorable::Operation
    
    def eval
      start_time = Time.now
      mappings = {}
      source_items = @args[:input].each_item
      target_items = @args[:target].each_item
      diff_items = source_items - target_items
      mappings = diff_items.map{|item| [item,{}]}.to_h

      finish_time = Time.now
      puts "EXECUTED DIFF: " << (finish_time - start_time).to_s
      mappings
    end
    
    def expression
      "diff(#{@args[:input].id}, #{@args[:input].id})"
    end
  end
  
  def diff(target)
    args = {target: target}
    
    execute_operation(Diff, args)
  end
end