module Explorable
  class Group < Explorable::Operation
    attr_accessor :grouping_function
    def horizontal?
      grouping_function.horizontal?
    end
    
    def eval_item(item)
      item_results = Set.new
      item_to_group = nil
        
      grouping_items = @grouping_function.group(item, @groups)

      grouping_items = [grouping_items] if !grouping_items.respond_to? :each
      if(!grouping_items.empty?)
        item.parents = grouping_items
        item_results << item
      end
      
      item_results
    end
    
    def prepare(args)
      start_time = Time.now
      input_set = @args[:input]
      @groups = {}
      @grouping_function = @args[:function]
      @grouping_function.prepare(input_set.each_item, @groups, input_set.server)
      finish_time = Time.now
      puts "EXECUTED GROUP: " << (finish_time - start_time).to_s
    end
    
    def expression
      "group(#{@args[:input].id}){#{@args[:function].expression}}"
    end
  end
  
  def group(args = {})
    args[:function] = yield(Grouping)
    execute_operation(Group, args)
  end
end